import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';
import { UserSetting } from './entities/user-setting.entity';
import { WeeklyGoal } from './entities/weekly-goal.entity';

type UpdateWeeklyGoalInput = {
  userId: string;
  targetHours: number;
  notificationEnabled?: boolean;
};

type UpdateSettingInput = {
  userId: string;
  key: string;
  value: Record<string, unknown>;
};

@Injectable()
export class MyService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
    @InjectRepository(UserQualification)
    private readonly userQualificationsRepository: Repository<UserQualification>,
    @InjectRepository(StudySession)
    private readonly studySessionsRepository: Repository<StudySession>,
    @InjectRepository(UserSetting)
    private readonly userSettingsRepository: Repository<UserSetting>,
    @InjectRepository(WeeklyGoal)
    private readonly weeklyGoalsRepository: Repository<WeeklyGoal>,
  ) {}

  async getMy(userId: string) {
    if (!userId?.trim()) {
      throw new BadRequestException('userId is required.');
    }

    const normalizedUserId = userId.trim();
    const user = await this.usersRepository.findOne({
      where: { id: normalizedUserId },
    });

    if (!user) {
      throw new NotFoundException(`User not found: ${normalizedUserId}`);
    }

    const userQualifications = await this.userQualificationsRepository.find({
      where: { userId: normalizedUserId },
      relations: {
        qualification: true,
      },
      order: {
        createdAt: 'DESC',
      },
    });

    const sessions = await this.studySessionsRepository.find({
      where: { userId: normalizedUserId },
      order: {
        startedAt: 'DESC',
      },
    });
    const userSettings = await this.userSettingsRepository.find({
      where: { userId: normalizedUserId },
      order: {
        key: 'ASC',
      },
    });
    const weeklyGoal = await this.getOrCreateWeeklyGoal(normalizedUserId);

    const weeklySeconds = this.getCurrentWeekSessions(sessions).reduce(
      (sum, session) => sum + (session.durationSeconds || 0),
      0,
    );
    const weeklyGoalHours = weeklyGoal.targetHours;
    const weeklyGoalSeconds = weeklyGoalHours * 60 * 60;
    const weeklyProgressRate = Math.min(
      100,
      Math.round((weeklySeconds / weeklyGoalSeconds) * 100),
    );
    const completedQualifications = userQualifications.filter(
      (item) => item.completedAt,
    ).length;

    return {
      profile: {
        id: user.id,
        displayName: user.displayName,
        email: user.email,
        level: user.level,
        streakDays: user.streakDays,
        profileImageUrl: user.profileImageUrl,
      },
      stats: {
        totalStudyMinutes: user.totalStudyMinutes,
        earnedCertificatesCount:
          user.earnedCertificatesCount || completedQualifications,
        progressRate: Number(user.progressRate),
        qualificationCount: userQualifications.length,
      },
      weeklyGoal: {
        targetHours: weeklyGoalHours,
        achievedMinutes: Math.floor(weeklySeconds / 60),
        progressRate: weeklyProgressRate,
        notificationEnabled: weeklyGoal.notificationEnabled,
      },
      recentActivity: sessions.slice(0, 5).map((session) => ({
        id: session.id,
        startedAt: session.startedAt,
        endedAt: session.endedAt,
        durationSeconds: session.durationSeconds,
      })),
      achievements: this.buildAchievements(user, weeklyProgressRate),
      settings: userSettings.map((setting) => ({
        key: setting.key,
        value: setting.value,
      })),
    };
  }

  async updateWeeklyGoal(input: UpdateWeeklyGoalInput) {
    if (!input.userId?.trim()) {
      throw new BadRequestException('userId is required.');
    }

    if (!input.targetHours || input.targetHours <= 0) {
      throw new BadRequestException('targetHours must be greater than 0.');
    }

    await this.ensureUserExists(input.userId.trim());

    const weeklyGoal = await this.getOrCreateWeeklyGoal(input.userId.trim());
    weeklyGoal.targetHours = input.targetHours;

    if (typeof input.notificationEnabled !== 'undefined') {
      weeklyGoal.notificationEnabled = input.notificationEnabled;
    }

    return this.weeklyGoalsRepository.save(weeklyGoal);
  }

  async updateSetting(input: UpdateSettingInput) {
    if (!input.userId?.trim() || !input.key?.trim()) {
      throw new BadRequestException('userId and key are required.');
    }

    await this.ensureUserExists(input.userId.trim());

    const existing = await this.userSettingsRepository.findOne({
      where: {
        userId: input.userId.trim(),
        key: input.key.trim(),
      },
    });

    if (existing) {
      existing.value = input.value ?? {};
      return this.userSettingsRepository.save(existing);
    }

    const setting = this.userSettingsRepository.create({
      userId: input.userId.trim(),
      key: input.key.trim(),
      value: input.value ?? {},
    });

    return this.userSettingsRepository.save(setting);
  }

  private getCurrentWeekSessions(sessions: StudySession[]) {
    const now = new Date();
    const startOfWeek = new Date(now);
    const day = startOfWeek.getDay();
    const diff = day === 0 ? 6 : day - 1;
    startOfWeek.setDate(startOfWeek.getDate() - diff);
    startOfWeek.setHours(0, 0, 0, 0);

    return sessions.filter(
      (session) => new Date(session.startedAt).getTime() >= startOfWeek.getTime(),
    );
  }

  private buildAchievements(user: User, weeklyProgressRate: number) {
    const achievements: Array<{
      key: string;
      title: string;
      value: string;
    }> = [];

    if (user.streakDays >= 7) {
      achievements.push({
        key: 'seven-day-streak',
        title: '7 Day Study Streak',
        value: `${user.streakDays} days`,
      });
    }

    if (weeklyProgressRate >= 100) {
      achievements.push({
        key: 'weekly-goal',
        title: 'Weekly Goal Complete',
        value: `${weeklyProgressRate}%`,
      });
    }

    return achievements;
  }

  private async ensureUserExists(userId: string) {
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException(`User not found: ${userId}`);
    }

    return user;
  }

  private async getOrCreateWeeklyGoal(userId: string) {
    const existing = await this.weeklyGoalsRepository.findOne({
      where: { userId },
    });

    if (existing) {
      return existing;
    }

    const weeklyGoal = this.weeklyGoalsRepository.create({
      userId,
      targetHours: 20,
      notificationEnabled: true,
    });

    return this.weeklyGoalsRepository.save(weeklyGoal);
  }
}
