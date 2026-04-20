import { Body, Controller, Delete, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { UserQualificationStatus } from './entities/user-qualification.entity';
import { UserQualificationsService } from './user-qualifications.service';

@Controller('user-qualifications')
export class UserQualificationsController {
  constructor(
    private readonly userQualificationsService: UserQualificationsService,
  ) {}

  @Get()
  getUserQualifications(@Query('userId') userId: string) {
    return this.userQualificationsService.getUserQualifications(userId);
  }

  @Post()
  createUserQualification(
    @Body('userId') userId: string,
    @Body('qualificationCode') qualificationCode: string,
    @Body('status') status?: UserQualificationStatus,
    @Body('examDate') examDate?: string,
    @Body('isPinned') isPinned?: boolean,
  ) {
    return this.userQualificationsService.createUserQualification({
      userId,
      qualificationCode,
      status,
      examDate,
      isPinned,
    });
  }

  @Patch(':id')
  updateUserQualification(
    @Param('id') id: string,
    @Body('status') status?: UserQualificationStatus,
    @Body('examDate') examDate?: string,
    @Body('isPinned') isPinned?: boolean,
    @Body('sortOrder') sortOrder?: number,
  ) {
    return this.userQualificationsService.updateUserQualification(id, {
      status,
      examDate,
      isPinned,
      sortOrder,
    });
  }

  @Delete(':id')
  deleteUserQualification(@Param('id') id: string) {
    return this.userQualificationsService.deleteUserQualification(id);
  }
}
