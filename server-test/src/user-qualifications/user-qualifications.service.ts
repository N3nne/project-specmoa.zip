import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Qualification } from '../qualifications/entities/qualification.entity';
import {
  UserQualification,
  UserQualificationStatus,
} from './entities/user-qualification.entity';

type CreateUserQualificationInput = {
  userId: string;
  qualificationCode: string;
  status?: UserQualificationStatus;
  examDate?: string;
  isPinned?: boolean;
};

type UpdateUserQualificationInput = {
  status?: UserQualificationStatus;
  examDate?: string;
  isPinned?: boolean;
  sortOrder?: number;
};

@Injectable()
export class UserQualificationsService {
  constructor(
    @InjectRepository(UserQualification)
    private readonly userQualificationsRepository: Repository<UserQualification>,
    @InjectRepository(Qualification)
    private readonly qualificationsRepository: Repository<Qualification>,
  ) {}

  async getUserQualifications(userId: string) {
    if (!userId?.trim()) {
      throw new BadRequestException('userId is required.');
    }

    const items = await this.userQualificationsRepository.find({
      where: { userId: userId.trim() },
      relations: {
        qualification: true,
      },
      order: {
        isPinned: 'DESC',
        sortOrder: 'ASC',
        createdAt: 'ASC',
      },
    });

    return {
      totalCount: items.length,
      items: items.map((item) => ({
        ...item,
        dDay: this.calculateDDay(item.examDate),
      })),
    };
  }

  async createUserQualification(input: CreateUserQualificationInput) {
    if (!input.userId?.trim() || !input.qualificationCode?.trim()) {
      throw new BadRequestException(
        'userId and qualificationCode are required.',
      );
    }

    const qualification = await this.qualificationsRepository.findOne({
      where: { code: input.qualificationCode.trim() },
    });

    if (!qualification) {
      throw new NotFoundException(
        `Qualification not found: ${input.qualificationCode}`,
      );
    }

    const existing = await this.userQualificationsRepository.findOne({
      where: {
        userId: input.userId.trim(),
        qualificationId: qualification.id,
      },
      relations: {
        qualification: true,
      },
    });

    if (existing) {
      return existing;
    }

    const userQualification = this.userQualificationsRepository.create({
      userId: input.userId.trim(),
      qualificationId: qualification.id,
      status: input.status ?? UserQualificationStatus.PREPARING,
      examDate: input.examDate ?? null,
      isPinned: input.isPinned ?? false,
      startedAt:
        input.status === UserQualificationStatus.IN_PROGRESS ? new Date() : null,
    });

    return this.userQualificationsRepository.save(userQualification);
  }

  async updateUserQualification(id: string, input: UpdateUserQualificationInput) {
    const item = await this.userQualificationsRepository.findOne({
      where: { id },
      relations: {
        qualification: true,
      },
    });

    if (!item) {
      throw new NotFoundException(`User qualification not found: ${id}`);
    }

    if (input.status) {
      item.status = input.status;
      if (input.status === UserQualificationStatus.IN_PROGRESS && !item.startedAt) {
        item.startedAt = new Date();
      }
      if (input.status === UserQualificationStatus.COMPLETED && !item.completedAt) {
        item.completedAt = new Date();
      }
    }

    if (typeof input.examDate !== 'undefined') {
      item.examDate = input.examDate || null;
    }

    if (typeof input.isPinned !== 'undefined') {
      item.isPinned = input.isPinned;
    }

    if (typeof input.sortOrder !== 'undefined') {
      item.sortOrder = input.sortOrder;
    }

    return this.userQualificationsRepository.save(item);
  }

  async deleteUserQualification(id: string) {
    const item = await this.userQualificationsRepository.findOne({
      where: { id },
    });

    if (!item) {
      throw new NotFoundException(`User qualification not found: ${id}`);
    }

    await this.userQualificationsRepository.remove(item);

    return {
      deleted: true,
      id,
    };
  }

  private calculateDDay(examDate?: string | null) {
    if (!examDate) {
      return null;
    }

    const today = new Date();
    const target = new Date(`${examDate}T00:00:00`);
    const diff = Math.ceil(
      (target.getTime() - new Date(today.toDateString()).getTime()) /
        (1000 * 60 * 60 * 24),
    );

    return diff;
  }
}
