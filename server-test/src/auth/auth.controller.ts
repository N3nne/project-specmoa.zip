import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('signup')
  signUp(
    @Body('displayName') displayName: string,
    @Body('email') email: string,
    @Body('password') password: string,
  ) {
    return this.authService.signUp({
      displayName,
      email,
      password,
    });
  }

  @Post('login')
  login(@Body('email') email: string, @Body('password') password: string) {
    return this.authService.login({
      email,
      password,
    });
  }
}
