import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('demo')
  createDemoUser() {
    return this.usersService.createDemoUser();
  }

  @Post()
  createUser(
    @Body('email') email: string,
    @Body('displayName') displayName: string,
  ) {
    return this.usersService.createUser({ email, displayName });
  }

  @Get()
  getUsers() {
    return this.usersService.getUsers();
  }

  @Get(':id')
  getUser(@Param('id') id: string) {
    return this.usersService.getUserById(id);
  }
}
