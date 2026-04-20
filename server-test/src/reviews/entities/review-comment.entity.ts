import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Review } from './review.entity';

@Entity('review_comments')
export class ReviewComment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'review_id' })
  reviewId: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'text' })
  content: string;

  @ManyToOne(() => Review, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'review_id' })
  review: Review;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
