import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';
import { MyController } from './my.controller';
import { UserSetting } from './entities/user-setting.entity';
import { WeeklyGoal } from './entities/weekly-goal.entity';
import { MyService } from './my.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      UserQualification,
      StudySession,
      UserSetting,
      WeeklyGoal,
    ]),
  ],
  controllers: [MyController],
  providers: [MyService],
})
export class MyModule {}
