import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomBytes, scryptSync, timingSafeEqual } from 'crypto';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';

type SignUpInput = {
  displayName: string;
  email: string;
  password: string;
};

type LoginInput = {
  email: string;
  password: string;
};

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async signUp(input: SignUpInput) {
    const displayName = input.displayName?.trim();
    const email = input.email?.trim().toLowerCase();
    const password = input.password?.trim();

    if (!displayName || !email || !password) {
      throw new BadRequestException(
        'displayName, email, and password are required.',
      );
    }

    if (password.length < 6) {
      throw new BadRequestException('password must be at least 6 characters.');
    }

    const existing = await this.usersRepository.findOne({
      where: { email },
    });

    if (existing) {
      throw new BadRequestException('이미 사용 중인 이메일입니다.');
    }

    const user = this.usersRepository.create({
      displayName,
      email,
      password: this.hashPassword(password),
    });

    const savedUser = await this.usersRepository.save(user);
    return this.toAuthUser(savedUser);
  }

  async login(input: LoginInput) {
    const email = input.email?.trim().toLowerCase();
    const password = input.password?.trim();

    if (!email || !password) {
      throw new BadRequestException('email and password are required.');
    }

    const user = await this.usersRepository.findOne({
      where: { email },
    });

    if (!user?.password || !this.verifyPassword(password, user.password)) {
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    return this.toAuthUser(user);
  }

  private toAuthUser(user: User) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      profileImageUrl: user.profileImageUrl,
      level: user.level,
      streakDays: user.streakDays,
    };
  }

  private hashPassword(password: string) {
    const salt = randomBytes(16).toString('hex');
    const hash = scryptSync(password, salt, 64).toString('hex');
    return `${salt}:${hash}`;
  }

  private verifyPassword(password: string, storedPassword: string) {
    const [salt, storedHash] = storedPassword.split(':');

    if (!salt || !storedHash) {
      return false;
    }

    const derivedHash = scryptSync(password, salt, 64);
    const storedBuffer = Buffer.from(storedHash, 'hex');

    if (derivedHash.length !== storedBuffer.length) {
      return false;
    }

    return timingSafeEqual(derivedHash, storedBuffer);
  }
}
