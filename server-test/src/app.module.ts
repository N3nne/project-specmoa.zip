import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { typeOrmConfig } from './database/typeorm.config';
import { HomeModule } from './home/home.module';
import { MyModule } from './my/my.module';
import { QuestionsModule } from './questions/questions.module';
import { QualificationsModule } from './qualifications/qualifications.module';
import { ReviewsModule } from './reviews/reviews.module';
import { StudySessionsModule } from './study-sessions/study-sessions.module';
import { UserQualificationsModule } from './user-qualifications/user-qualifications.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRoot(typeOrmConfig),
    AuthModule,
    HomeModule,
    MyModule,
    QuestionsModule,
    QualificationsModule,
    ReviewsModule,
    UsersModule,
    UserQualificationsModule,
    StudySessionsModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
