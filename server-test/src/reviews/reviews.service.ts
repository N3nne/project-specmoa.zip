import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Qualification } from '../qualifications/entities/qualification.entity';
import { User } from '../users/entities/user.entity';
import { ReviewComment } from './entities/review-comment.entity';
import { Review } from './entities/review.entity';

type ReviewQuery = {
  qualificationCode?: string;
  featured?: string;
};

type CreateReviewInput = {
  userId: string;
  qualificationCode: string;
  title: string;
  content: string;
  studyPeriodText?: string;
  tipSummary?: string;
};

type UpdateReviewInput = {
  title?: string;
  content?: string;
  studyPeriodText?: string;
  tipSummary?: string;
};

type CreateReviewCommentInput = {
  userId: string;
  content: string;
};

type UpdateReviewCommentInput = {
  content?: string;
};

@Injectable()
export class ReviewsService {
  constructor(
    @InjectRepository(Review)
    private readonly reviewsRepository: Repository<Review>,
    @InjectRepository(ReviewComment)
    private readonly reviewCommentsRepository: Repository<ReviewComment>,
    @InjectRepository(Qualification)
    private readonly qualificationsRepository: Repository<Qualification>,
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async getReviews(query: ReviewQuery) {
    const qualificationCode = query.qualificationCode?.trim();
    const featuredOnly = query.featured?.trim() === 'true';

    const items = await this.reviewsRepository.find({
      where: {
        qualificationCode: qualificationCode || undefined,
        isFeatured: featuredOnly ? true : undefined,
      },
      relations: {
        qualification: true,
        user: true,
      },
      order: {
        isFeatured: 'DESC',
        likeCount: 'DESC',
        viewCount: 'DESC',
        createdAt: 'DESC',
      },
      take: featuredOnly ? 10 : 30,
    });

    return {
      totalCount: items.length,
      items: items.map((item) => this.mapReviewListItem(item)),
    };
  }

  async getReviewDetail(id: string) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    const review = await this.reviewsRepository.findOne({
      where: { id: id.trim() },
      relations: {
        qualification: true,
        user: true,
      },
    });

    if (!review) {
      throw new NotFoundException(`Review not found: ${id}`);
    }

    review.viewCount += 1;
    await this.reviewsRepository.save(review);

    const comments = await this.reviewCommentsRepository.find({
      where: { reviewId: review.id },
      relations: {
        user: true,
      },
      order: {
        createdAt: 'ASC',
      },
    });

    return {
      ...this.mapReviewListItem(review),
      qualificationName: review.qualification?.name ?? null,
      commentCount: comments.length,
      comments: comments.map((comment) => ({
        id: comment.id,
        userId: comment.userId,
        author: comment.user?.displayName ?? null,
        content: comment.content,
        createdAt: comment.createdAt,
      })),
    };
  }

  async createReview(input: CreateReviewInput) {
    if (
      !input.userId?.trim() ||
      !input.qualificationCode?.trim() ||
      !input.title?.trim() ||
      !input.content?.trim()
    ) {
      throw new BadRequestException(
        'userId, qualificationCode, title, and content are required.',
      );
    }

    const user = await this.usersRepository.findOne({
      where: { id: input.userId.trim() },
    });
    if (!user) {
      throw new NotFoundException(`User not found: ${input.userId}`);
    }

    const qualification = await this.qualificationsRepository.findOne({
      where: { code: input.qualificationCode.trim() },
    });
    if (!qualification) {
      throw new NotFoundException(
        `Qualification not found: ${input.qualificationCode}`,
      );
    }

    const review = this.reviewsRepository.create({
      userId: input.userId.trim(),
      qualificationCode: input.qualificationCode.trim(),
      title: input.title.trim(),
      content: input.content.trim(),
      studyPeriodText: input.studyPeriodText?.trim() || null,
      tipSummary: input.tipSummary?.trim() || null,
      isFeatured: false,
    });

    return this.reviewsRepository.save(review);
  }

  async createReviewComment(id: string, input: CreateReviewCommentInput) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    if (!input.userId?.trim() || !input.content?.trim()) {
      throw new BadRequestException('userId and content are required.');
    }

    const review = await this.reviewsRepository.findOne({
      where: { id: id.trim() },
    });
    if (!review) {
      throw new NotFoundException(`Review not found: ${id}`);
    }

    const user = await this.usersRepository.findOne({
      where: { id: input.userId.trim() },
    });
    if (!user) {
      throw new NotFoundException(`User not found: ${input.userId}`);
    }

    const comment = this.reviewCommentsRepository.create({
      reviewId: review.id,
      userId: user.id,
      content: input.content.trim(),
    });

    const savedComment = await this.reviewCommentsRepository.save(comment);

    return {
      id: savedComment.id,
      reviewId: savedComment.reviewId,
      userId: savedComment.userId,
      author: user.displayName,
      content: savedComment.content,
      createdAt: savedComment.createdAt,
    };
  }

  async updateReviewComment(
    commentId: string,
    input: UpdateReviewCommentInput,
  ) {
    if (!commentId?.trim()) {
      throw new BadRequestException('commentId is required.');
    }

    const comment = await this.reviewCommentsRepository.findOne({
      where: { id: commentId.trim() },
      relations: {
        user: true,
      },
    });

    if (!comment) {
      throw new NotFoundException(`Review comment not found: ${commentId}`);
    }

    if (typeof input.content !== 'undefined') {
      if (!input.content?.trim()) {
        throw new BadRequestException('content cannot be empty.');
      }
      comment.content = input.content.trim();
    }

    const savedComment = await this.reviewCommentsRepository.save(comment);

    return {
      id: savedComment.id,
      reviewId: savedComment.reviewId,
      userId: savedComment.userId,
      author: savedComment.user?.displayName ?? null,
      content: savedComment.content,
      createdAt: savedComment.createdAt,
      updatedAt: savedComment.updatedAt,
    };
  }

  async deleteReviewComment(commentId: string) {
    if (!commentId?.trim()) {
      throw new BadRequestException('commentId is required.');
    }

    const comment = await this.reviewCommentsRepository.findOne({
      where: { id: commentId.trim() },
    });

    if (!comment) {
      throw new NotFoundException(`Review comment not found: ${commentId}`);
    }

    await this.reviewCommentsRepository.remove(comment);

    return {
      id: comment.id,
      deleted: true,
    };
  }

  async updateReview(id: string, input: UpdateReviewInput) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    const review = await this.reviewsRepository.findOne({
      where: { id: id.trim() },
    });

    if (!review) {
      throw new NotFoundException(`Review not found: ${id}`);
    }

    if (typeof input.title !== 'undefined') {
      if (!input.title?.trim()) {
        throw new BadRequestException('title cannot be empty.');
      }
      review.title = input.title.trim();
    }

    if (typeof input.content !== 'undefined') {
      if (!input.content?.trim()) {
        throw new BadRequestException('content cannot be empty.');
      }
      review.content = input.content.trim();
    }

    if (typeof input.studyPeriodText !== 'undefined') {
      review.studyPeriodText = input.studyPeriodText?.trim() || null;
    }

    if (typeof input.tipSummary !== 'undefined') {
      review.tipSummary = input.tipSummary?.trim() || null;
    }

    return this.reviewsRepository.save(review);
  }

  async deleteReview(id: string) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    const review = await this.reviewsRepository.findOne({
      where: { id: id.trim() },
    });

    if (!review) {
      throw new NotFoundException(`Review not found: ${id}`);
    }

    await this.reviewsRepository.remove(review);

    return {
      id: review.id,
      deleted: true,
    };
  }

  private mapReviewListItem(review: Review) {
    return {
      id: review.id,
      userId: review.userId,
      qualificationCode: review.qualificationCode,
      qualificationName: review.qualification?.name ?? null,
      title: review.title,
      content: review.content,
      studyPeriodText: review.studyPeriodText,
      tipSummary: review.tipSummary,
      likeCount: review.likeCount,
      viewCount: review.viewCount,
      isFeatured: review.isFeatured,
      author: review.user?.displayName ?? null,
      createdAt: review.createdAt,
    };
  }
}
