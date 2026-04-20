import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { StudySessionsService } from './study-sessions.service';

@Controller('study-sessions')
export class StudySessionsController {
  constructor(private readonly studySessionsService: StudySessionsService) {}

  @Post('start')
  startSession(
    @Body('userId') userId: string,
    @Body('userQualificationId') userQualificationId: string,
    @Body('goalDurationSeconds') goalDurationSeconds?: number,
    @Body('memo') memo?: string,
  ) {
    return this.studySessionsService.startSession({
      userId,
      userQualificationId,
      goalDurationSeconds,
      memo,
    });
  }

  @Patch(':id/stop')
  stopSession(@Param('id') id: string) {
    return this.studySessionsService.stopSession(id);
  }

  @Get()
  getSessions(@Query('userId') userId: string) {
    return this.studySessionsService.getSessions(userId);
  }

  @Get('summary/today')
  getTodaySummary(@Query('userId') userId: string) {
    return this.studySessionsService.getTodaySummary(userId);
  }
}
