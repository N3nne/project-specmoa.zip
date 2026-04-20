import { Body, Controller, Get, Patch, Query } from '@nestjs/common';
import { MyService } from './my.service';

@Controller('my')
export class MyController {
  constructor(private readonly myService: MyService) {}

  @Get()
  getMy(@Query('userId') userId: string) {
    return this.myService.getMy(userId);
  }

  @Patch('weekly-goal')
  updateWeeklyGoal(
    @Body('userId') userId: string,
    @Body('targetHours') targetHours: number,
    @Body('notificationEnabled') notificationEnabled?: boolean,
  ) {
    return this.myService.updateWeeklyGoal({
      userId,
      targetHours,
      notificationEnabled,
    });
  }

  @Patch('settings')
  updateSetting(
    @Body('userId') userId: string,
    @Body('key') key: string,
    @Body('value') value: Record<string, unknown>,
  ) {
    return this.myService.updateSetting({
      userId,
      key,
      value,
    });
  }
}
