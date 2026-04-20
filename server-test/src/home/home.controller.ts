import { Controller, Get, Query } from '@nestjs/common';
import { HomeService } from './home.service';

@Controller('home')
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Get()
  getHome(@Query('userId') userId: string) {
    return this.homeService.getHome(userId);
  }
}
