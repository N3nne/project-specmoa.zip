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
import { ReviewsService } from './reviews.service';

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Get()
  getReviews(
    @Query('qualificationCode') qualificationCode?: string,
    @Query('featured') featured?: string,
  ) {
    return this.reviewsService.getReviews({
      qualificationCode,
      featured,
    });
  }

  @Get(':id')
  getReviewDetail(@Param('id') id: string) {
    return this.reviewsService.getReviewDetail(id);
  }

  @Post()
  createReview(
    @Body('userId') userId: string,
    @Body('qualificationCode') qualificationCode: string,
    @Body('title') title: string,
    @Body('content') content: string,
    @Body('studyPeriodText') studyPeriodText?: string,
    @Body('tipSummary') tipSummary?: string,
  ) {
    return this.reviewsService.createReview({
      userId,
      qualificationCode,
      title,
      content,
      studyPeriodText,
      tipSummary,
    });
  }

  @Post(':id/comments')
  createReviewComment(
    @Param('id') id: string,
    @Body('userId') userId: string,
    @Body('content') content: string,
  ) {
    return this.reviewsService.createReviewComment(id, {
      userId,
      content,
    });
  }

  @Patch('comments/:commentId')
  updateReviewComment(
    @Param('commentId') commentId: string,
    @Body('content') content: string,
  ) {
    return this.reviewsService.updateReviewComment(commentId, {
      content,
    });
  }

  @Delete('comments/:commentId')
  deleteReviewComment(@Param('commentId') commentId: string) {
    return this.reviewsService.deleteReviewComment(commentId);
  }

  @Patch(':id')
  updateReview(
    @Param('id') id: string,
    @Body('title') title: string,
    @Body('content') content: string,
    @Body('studyPeriodText') studyPeriodText?: string,
    @Body('tipSummary') tipSummary?: string,
  ) {
    return this.reviewsService.updateReview(id, {
      title,
      content,
      studyPeriodText,
      tipSummary,
    });
  }

  @Delete(':id')
  deleteReview(@Param('id') id: string) {
    return this.reviewsService.deleteReview(id);
  }
}
