import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';
import { StudySession } from './entities/study-session.entity';

type StartSessionInput = {
  userId: string;
  userQualificationId: string;
  goalDurationSeconds?: number;
  memo?: string;
};

@Injectable()
export class StudySessionsService {
  constructor(
    @InjectRepository(StudySession)
    private readonly studySessionsRepository: Repository<StudySession>,
    @InjectRepository(UserQualification)
    private readonly userQualificationsRepository: Repository<UserQualification>,
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async startSession(input: StartSessionInput) {
    if (!input.userId?.trim() || !input.userQualificationId?.trim()) {
      throw new BadRequestException(
        'userId and userQualificationId are required.',
      );
    }

    const userQualification = await this.userQualificationsRepository.findOne({
      where: {
        id: input.userQualificationId.trim(),
        userId: input.userId.trim(),
      },
    });

    if (!userQualification) {
      throw new NotFoundException(
        `User qualification not found: ${input.userQualificationId}`,
      );
    }

    const session = this.studySessionsRepository.create({
      userId: input.userId.trim(),
      userQualificationId: input.userQualificationId.trim(),
      startedAt: new Date(),
      goalDurationSeconds: input.goalDurationSeconds ?? null,
      memo: input.memo?.trim() || null,
    });

    return this.studySessionsRepository.save(session);
  }

  async stopSession(id: string) {
    const session = await this.studySessionsRepository.findOne({
      where: { id },
    });

    if (!session) {
      throw new NotFoundException(`Study session not found: ${id}`);
    }

    if (session.endedAt) {
      return session;
    }

    session.endedAt = new Date();
    session.durationSeconds = Math.max(
      0,
      Math.floor(
        (session.endedAt.getTime() - session.startedAt.getTime()) / 1000,
      ),
    );

    const savedSession = await this.studySessionsRepository.save(session);
    const trackedMinutes = this.secondsToTrackedMinutes(
      savedSession.durationSeconds,
    );

    await this.userQualificationsRepository.increment(
      { id: session.userQualificationId },
      'totalStudyMinutes',
      trackedMinutes,
    );

    await this.userQualificationsRepository.update(
      { id: session.userQualificationId },
      { lastStudiedAt: session.endedAt },
    );

    await this.usersRepository.increment(
      { id: session.userId },
      'totalStudyMinutes',
      trackedMinutes,
    );

    return savedSession;
  }

  async getSessions(userId: string) {
    if (!userId?.trim()) {
      throw new BadRequestException('userId is required.');
    }

    return this.studySessionsRepository.find({
      where: { userId: userId.trim() },
      order: {
        startedAt: 'DESC',
      },
    });
  }

  async getTodaySummary(userId: string) {
    if (!userId?.trim()) {
      throw new BadRequestException('userId is required.');
    }

    const sessions = await this.studySessionsRepository.find({
      where: { userId: userId.trim() },
      order: {
        startedAt: 'DESC',
      },
    });

    const today = new Date().toDateString();
    const todaySessions = sessions.filter(
      (session) => new Date(session.startedAt).toDateString() === today,
    );
    const totalDurationSeconds = todaySessions.reduce(
      (sum, session) => sum + (session.durationSeconds || 0),
      0,
    );

    return {
      sessionCount: todaySessions.length,
      totalDurationSeconds,
      totalDurationMinutes: this.secondsToTrackedMinutes(totalDurationSeconds),
      items: todaySessions,
    };
  }

  private secondsToTrackedMinutes(totalSeconds: number) {
    if (totalSeconds <= 0) {
      return 0;
    }

    return Math.max(1, Math.ceil(totalSeconds / 60));
  }
}
