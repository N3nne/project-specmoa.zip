import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { QuestionsService } from './questions.service';

@Controller('questions')
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  @Get()
  getQuestions(
    @Query('qualificationCode') qualificationCode?: string,
    @Query('popular') popular?: string,
  ) {
    return this.questionsService.getQuestions({
      qualificationCode,
      popular,
    });
  }

  @Get(':id')
  getQuestionDetail(@Param('id') id: string) {
    return this.questionsService.getQuestionDetail(id);
  }

  @Post()
  createQuestion(
    @Body('userId') userId: string,
    @Body('qualificationCode') qualificationCode: string,
    @Body('title') title: string,
    @Body('content') content: string,
  ) {
    return this.questionsService.createQuestion({
      userId,
      qualificationCode,
      title,
      content,
    });
  }

  @Post(':id/comments')
  createQuestionComment(
    @Param('id') id: string,
    @Body('userId') userId: string,
    @Body('content') content: string,
  ) {
    return this.questionsService.createQuestionComment(id, {
      userId,
      content,
    });
  }

  @Patch('comments/:commentId')
  updateQuestionComment(
    @Param('commentId') commentId: string,
    @Body('content') content: string,
  ) {
    return this.questionsService.updateQuestionComment(commentId, {
      content,
    });
  }

  @Delete('comments/:commentId')
  deleteQuestionComment(@Param('commentId') commentId: string) {
    return this.questionsService.deleteQuestionComment(commentId);
  }

  @Patch(':id')
  updateQuestion(
    @Param('id') id: string,
    @Body('title') title: string,
    @Body('content') content: string,
  ) {
    return this.questionsService.updateQuestion(id, {
      title,
      content,
    });
  }

  @Delete(':id')
  deleteQuestion(@Param('id') id: string) {
    return this.questionsService.deleteQuestion(id);
  }
}
