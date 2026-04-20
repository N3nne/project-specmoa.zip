import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Qualification } from '../qualifications/entities/qualification.entity';
import { UserQualification } from './entities/user-qualification.entity';
import { UserQualificationsController } from './user-qualifications.controller';
import { UserQualificationsService } from './user-qualifications.service';

@Module({
  imports: [TypeOrmModule.forFeature([UserQualification, Qualification])],
  controllers: [UserQualificationsController],
  providers: [UserQualificationsService],
  exports: [UserQualificationsService],
})
export class UserQualificationsModule {}
