import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';
import { StudySession } from './entities/study-session.entity';
import { StudySessionsController } from './study-sessions.controller';
import { StudySessionsService } from './study-sessions.service';

@Module({
  imports: [TypeOrmModule.forFeature([StudySession, UserQualification, User])],
  controllers: [StudySessionsController],
  providers: [StudySessionsService],
})
export class StudySessionsModule {}
