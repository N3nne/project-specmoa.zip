import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { WeeklyGoal } from '../my/entities/weekly-goal.entity';
import { UserSetting } from '../my/entities/user-setting.entity';
import { QuestionComment } from '../questions/entities/question-comment.entity';
import { Question } from '../questions/entities/question.entity';
import { Qualification } from '../qualifications/entities/qualification.entity';
import { ReviewComment } from '../reviews/entities/review-comment.entity';
import { Review } from '../reviews/entities/review.entity';
import { StudySession } from '../study-sessions/entities/study-session.entity';
import { UserQualification } from '../user-qualifications/entities/user-qualification.entity';
import { User } from '../users/entities/user.entity';

const defaultPort = 5432;

export const typeOrmConfig: TypeOrmModuleOptions = {
  type: 'postgres',
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? defaultPort),
  username: process.env.DB_USERNAME ?? 'postgres',
  password: process.env.DB_PASSWORD ?? 'postgres',
  database: process.env.DB_NAME ?? 'server_test',
  entities: [
    User,
    Qualification,
    UserQualification,
    StudySession,
    Question,
    QuestionComment,
    Review,
    ReviewComment,
    UserSetting,
    WeeklyGoal,
  ],
  autoLoadEntities: true,
  synchronize: process.env.DB_SYNCHRONIZE === 'true',
  logging: process.env.DB_LOGGING === 'true',
  retryAttempts: 3,
  retryDelay: 3000,
};
