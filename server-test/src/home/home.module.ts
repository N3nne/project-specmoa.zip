import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Question } from '../questions/entities/question.entity';
import { Qualification } from '../qualifications/entities/qualification.entity';
import { Review } from '../reviews/entities/review.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';
import { HomeController } from './home.controller';
import { HomeService } from './home.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      Qualification,
      UserQualification,
      StudySession,
      Question,
      Review,
    ]),
  ],
  controllers: [HomeController],
  providers: [HomeService],
})
export class HomeModule {}
