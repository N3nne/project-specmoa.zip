import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QualificationsController } from './qualifications.controller';
import { Qualification } from './entities/qualification.entity';
import { QualificationsService } from './qualifications.service';

@Module({
  imports: [TypeOrmModule.forFeature([Qualification])],
  controllers: [QualificationsController],
  providers: [QualificationsService],
})
export class QualificationsModule {}
