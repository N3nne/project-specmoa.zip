import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Question } from '../questions/entities/question.entity';
import { Qualification } from '../qualifications/entities/qualification.entity';
import { Review } from '../reviews/entities/review.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class HomeService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
    @InjectRepository(Qualification)
    private readonly qualificationsRepository: Repository<Qualification>,
    @InjectRepository(UserQualification)
    private readonly userQualificationsRepository: Repository<UserQualification>,
    @InjectRepository(StudySession)
    private readonly studySessionsRepository: Repository<StudySession>,
    @InjectRepository(Question)
    private readonly questionsRepository: Repository<Question>,
    @InjectRepository(Review)
    private readonly reviewsRepository: Repository<Review>,
  ) {}

  async getHome(userId: string) {
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

    const myQualifications = await this.userQualificationsRepository.find({
      where: { userId: normalizedUserId },
      relations: {
        qualification: true,
      },
      order: {
        isPinned: 'DESC',
        sortOrder: 'ASC',
        createdAt: 'ASC',
      },
      take: 4,
    });

    const allUserQualifications = await this.userQualificationsRepository.find({
      where: { userId: normalizedUserId },
      relations: {
        qualification: true,
      },
    });

    const featuredQualifications = await this.qualificationsRepository.find({
      where: { isFeatured: true },
      order: {
        name: 'ASC',
      },
      take: 6,
    });

    const popularQualifications =
      featuredQualifications.length > 0
        ? featuredQualifications
        : await this.qualificationsRepository.find({
            order: {
              name: 'ASC',
            },
            take: 6,
          });

    const sessions = await this.studySessionsRepository.find({
      where: { userId: normalizedUserId },
      order: {
        startedAt: 'DESC',
      },
    });
    const popularQuestions = await this.questionsRepository.find({
      relations: {
        qualification: true,
        user: true,
      },
      order: {
        isPopular: 'DESC',
        likeCount: 'DESC',
        commentCount: 'DESC',
        createdAt: 'DESC',
      },
      take: 5,
    });
    const passReviews = await this.reviewsRepository.find({
      relations: {
        qualification: true,
        user: true,
      },
      order: {
        isFeatured: 'DESC',
        likeCount: 'DESC',
        createdAt: 'DESC',
      },
      take: 5,
    });

    const today = new Date().toDateString();
    const todaySessions = sessions.filter(
      (session) => new Date(session.startedAt).toDateString() === today,
    );
    const todayStudySeconds = todaySessions.reduce(
      (sum, session) => sum + (session.durationSeconds || 0),
      0,
    );

    return {
      user: {
        id: user.id,
        displayName: user.displayName,
        level: user.level,
        streakDays: user.streakDays,
      },
      summary: {
        myQualificationCount: allUserQualifications.length,
        completedQualificationCount: allUserQualifications.filter(
          (item) => item.completedAt,
        ).length,
        todayStudyMinutes: Math.floor(todayStudySeconds / 60),
      },
      myQualifications: myQualifications.map((item) => ({
        id: item.id,
        qualificationCode: item.qualification.code,
        qualificationName: item.qualification.name,
        status: item.status,
        totalStudyMinutes: item.totalStudyMinutes,
        examDate: item.examDate,
        dDay: this.calculateDDay(item.examDate),
        difficulty: item.qualification.difficulty,
      })),
      popularQualifications: popularQualifications.map((item) => ({
        code: item.code,
        name: item.name,
        seriesName: item.seriesName,
        difficulty: item.difficulty,
        expectedStudyMinutes: item.expectedStudyMinutes,
        isFeatured: item.isFeatured,
      })),
      todayStudy: {
        sessionCount: todaySessions.length,
        totalDurationSeconds: todayStudySeconds,
        totalDurationMinutes: Math.floor(todayStudySeconds / 60),
      },
      popularQuestions: popularQuestions.map((item) => ({
        id: item.id,
        qualificationCode: item.qualificationCode,
        qualificationName: item.qualification?.name ?? null,
        title: item.title,
        likeCount: item.likeCount,
        commentCount: item.commentCount,
        author: item.user?.displayName ?? null,
      })),
      passReviews: passReviews.map((item) => ({
        id: item.id,
        qualificationCode: item.qualificationCode,
        qualificationName: item.qualification?.name ?? null,
        title: item.title,
        studyPeriodText: item.studyPeriodText,
        tipSummary: item.tipSummary,
        likeCount: item.likeCount,
        author: item.user?.displayName ?? null,
      })),
    };
  }

  private calculateDDay(examDate?: string | null) {
    if (!examDate) {
      return null;
    }

    const today = new Date();
    const target = new Date(`${examDate}T00:00:00`);
    return Math.ceil(
      (target.getTime() - new Date(today.toDateString()).getTime()) /
        (1000 * 60 * 60 * 24),
    );
  }
}
