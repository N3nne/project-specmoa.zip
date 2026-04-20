import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

type CreateUserInput = {
  email: string;
  displayName: string;
};

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async createDemoUser() {
    const demoDisplayName = '김민중';
    const existing = await this.usersRepository.findOne({
      where: { email: 'demo@specmoa.app' },
    });

    if (existing) {
      if (existing.displayName !== demoDisplayName) {
        existing.displayName = demoDisplayName;
        const savedUser = await this.usersRepository.save(existing);
        return this.toPublicUser(savedUser);
      }

      return this.toPublicUser(existing);
    }

    const user = this.usersRepository.create({
      email: 'demo@specmoa.app',
      displayName: demoDisplayName,
      level: 5,
      streakDays: 12,
      totalStudyMinutes: 245 * 60,
      earnedCertificatesCount: 3,
      progressRate: 4,
    });

    const savedUser = await this.usersRepository.save(user);
    return this.toPublicUser(savedUser);
  }

  async createUser(input: CreateUserInput) {
    if (!input.email?.trim() || !input.displayName?.trim()) {
      throw new BadRequestException('email and displayName are required.');
    }

    const existing = await this.usersRepository.findOne({
      where: { email: input.email.trim() },
    });

    if (existing) {
      return this.toPublicUser(existing);
    }

    const user = this.usersRepository.create({
      email: input.email.trim(),
      displayName: input.displayName.trim(),
    });

    const savedUser = await this.usersRepository.save(user);
    return this.toPublicUser(savedUser);
  }

  async getUsers() {
    const users = await this.usersRepository.find({
      order: {
        createdAt: 'ASC',
      },
    });

    return users.map((user) => this.toPublicUser(user));
  }

  async getUserById(id: string) {
    const user = await this.usersRepository.findOne({ where: { id } });

    if (!user) {
      throw new NotFoundException(`User not found: ${id}`);
    }

    return this.toPublicUser(user);
  }

  private toPublicUser(user: User) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      profileImageUrl: user.profileImageUrl,
      level: user.level,
      streakDays: user.streakDays,
      totalStudyMinutes: user.totalStudyMinutes,
      earnedCertificatesCount: user.earnedCertificatesCount,
      progressRate: Number(user.progressRate),
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }
}
