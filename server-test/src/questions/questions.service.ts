import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Qualification } from '../qualifications/entities/qualification.entity';
import { User } from '../users/entities/user.entity';
import { QuestionComment } from './entities/question-comment.entity';
import { Question } from './entities/question.entity';

type QuestionQuery = {
  qualificationCode?: string;
  popular?: string;
};

type CreateQuestionInput = {
  userId: string;
  qualificationCode: string;
  title: string;
  content: string;
};

type UpdateQuestionInput = {
  title?: string;
  content?: string;
};

type CreateQuestionCommentInput = {
  userId: string;
  content: string;
};

type UpdateQuestionCommentInput = {
  content?: string;
};

@Injectable()
export class QuestionsService {
  constructor(
    @InjectRepository(Question)
    private readonly questionsRepository: Repository<Question>,
    @InjectRepository(QuestionComment)
    private readonly questionCommentsRepository: Repository<QuestionComment>,
    @InjectRepository(Qualification)
    private readonly qualificationsRepository: Repository<Qualification>,
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  async getQuestions(query: QuestionQuery) {
    const qualificationCode = query.qualificationCode?.trim();
    const popularOnly = query.popular?.trim() === 'true';

    const items = await this.questionsRepository.find({
      where: {
        qualificationCode: qualificationCode || undefined,
        isPopular: popularOnly ? true : undefined,
      },
      relations: {
        qualification: true,
        user: true,
      },
      order: {
        isPopular: 'DESC',
        likeCount: 'DESC',
        commentCount: 'DESC',
        createdAt: 'DESC',
      },
      take: popularOnly ? 10 : 30,
    });

    return {
      totalCount: items.length,
      items: items.map((item) => this.mapQuestionListItem(item)),
    };
  }

  async getQuestionDetail(id: string) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    const question = await this.questionsRepository.findOne({
      where: { id: id.trim() },
      relations: {
        qualification: true,
        user: true,
      },
    });

    if (!question) {
      throw new NotFoundException(`Question not found: ${id}`);
    }

    question.viewCount += 1;
    await this.questionsRepository.save(question);

    const comments = await this.questionCommentsRepository.find({
      where: { questionId: question.id },
      relations: {
        user: true,
      },
      order: {
        createdAt: 'ASC',
      },
    });

    return {
      ...this.mapQuestionListItem(question),
      qualificationName: question.qualification?.name ?? null,
      comments: comments.map((comment) => ({
        id: comment.id,
        userId: comment.userId,
        author: comment.user?.displayName ?? null,
        content: comment.content,
        createdAt: comment.createdAt,
      })),
    };
  }

  async createQuestion(input: CreateQuestionInput) {
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

    const question = this.questionsRepository.create({
      userId: input.userId.trim(),
      qualificationCode: input.qualificationCode.trim(),
      title: input.title.trim(),
      content: input.content.trim(),
      isPopular: false,
    });

    return this.questionsRepository.save(question);
  }

  async createQuestionComment(id: string, input: CreateQuestionCommentInput) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    if (!input.userId?.trim() || !input.content?.trim()) {
      throw new BadRequestException('userId and content are required.');
    }

    const question = await this.questionsRepository.findOne({
      where: { id: id.trim() },
    });
    if (!question) {
      throw new NotFoundException(`Question not found: ${id}`);
    }

    const user = await this.usersRepository.findOne({
      where: { id: input.userId.trim() },
    });
    if (!user) {
      throw new NotFoundException(`User not found: ${input.userId}`);
    }

    const comment = this.questionCommentsRepository.create({
      questionId: question.id,
      userId: user.id,
      content: input.content.trim(),
    });

    const savedComment = await this.questionCommentsRepository.save(comment);
    question.commentCount += 1;
    await this.questionsRepository.save(question);

    return {
      id: savedComment.id,
      questionId: savedComment.questionId,
      userId: savedComment.userId,
      author: user.displayName,
      content: savedComment.content,
      createdAt: savedComment.createdAt,
    };
  }

  async updateQuestionComment(
    commentId: string,
    input: UpdateQuestionCommentInput,
  ) {
    if (!commentId?.trim()) {
      throw new BadRequestException('commentId is required.');
    }

    const comment = await this.questionCommentsRepository.findOne({
      where: { id: commentId.trim() },
      relations: {
        user: true,
      },
    });

    if (!comment) {
      throw new NotFoundException(`Question comment not found: ${commentId}`);
    }

    if (typeof input.content !== 'undefined') {
      if (!input.content?.trim()) {
        throw new BadRequestException('content cannot be empty.');
      }
      comment.content = input.content.trim();
    }

    const savedComment = await this.questionCommentsRepository.save(comment);

    return {
      id: savedComment.id,
      questionId: savedComment.questionId,
      userId: savedComment.userId,
      author: savedComment.user?.displayName ?? null,
      content: savedComment.content,
      createdAt: savedComment.createdAt,
      updatedAt: savedComment.updatedAt,
    };
  }

  async deleteQuestionComment(commentId: string) {
    if (!commentId?.trim()) {
      throw new BadRequestException('commentId is required.');
    }

    const comment = await this.questionCommentsRepository.findOne({
      where: { id: commentId.trim() },
    });

    if (!comment) {
      throw new NotFoundException(`Question comment not found: ${commentId}`);
    }

    await this.questionCommentsRepository.remove(comment);

    const question = await this.questionsRepository.findOne({
      where: { id: comment.questionId },
    });

    if (question) {
      question.commentCount = Math.max(0, question.commentCount - 1);
      await this.questionsRepository.save(question);
    }

    return {
      id: comment.id,
      deleted: true,
    };
  }

  async updateQuestion(id: string, input: UpdateQuestionInput) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    const question = await this.questionsRepository.findOne({
      where: { id: id.trim() },
    });

    if (!question) {
      throw new NotFoundException(`Question not found: ${id}`);
    }

    if (typeof input.title !== 'undefined') {
      if (!input.title?.trim()) {
        throw new BadRequestException('title cannot be empty.');
      }
      question.title = input.title.trim();
    }

    if (typeof input.content !== 'undefined') {
      if (!input.content?.trim()) {
        throw new BadRequestException('content cannot be empty.');
      }
      question.content = input.content.trim();
    }

    return this.questionsRepository.save(question);
  }

  async deleteQuestion(id: string) {
    if (!id?.trim()) {
      throw new BadRequestException('id is required.');
    }

    const question = await this.questionsRepository.findOne({
      where: { id: id.trim() },
    });

    if (!question) {
      throw new NotFoundException(`Question not found: ${id}`);
    }

    await this.questionsRepository.remove(question);

    return {
      id: question.id,
      deleted: true,
    };
  }

  private mapQuestionListItem(question: Question) {
    return {
      id: question.id,
      userId: question.userId,
      qualificationCode: question.qualificationCode,
      qualificationName: question.qualification?.name ?? null,
      title: question.title,
      content: question.content,
      likeCount: question.likeCount,
      commentCount: question.commentCount,
      viewCount: question.viewCount,
      isPopular: question.isPopular,
      author: question.user?.displayName ?? null,
      createdAt: question.createdAt,
    };
  }
}
