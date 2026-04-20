import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Qualification } from '../../qualifications/entities/qualification.entity';
import { User } from '../../users/entities/user.entity';

@Entity('reviews')
export class Review {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'qualification_code', length: 50 })
  qualificationCode: string;

  @Column({ length: 200 })
  title: string;

  @Column({ type: 'text' })
  content: string;

  @Column({
    name: 'study_period_text',
    type: 'varchar',
    length: 100,
    nullable: true,
  })
  studyPeriodText: string | null;

  @Column({ name: 'tip_summary', type: 'text', nullable: true })
  tipSummary: string | null;

  @Column({ name: 'like_count', default: 0 })
  likeCount: number;

  @Column({ name: 'view_count', default: 0 })
  viewCount: number;

  @Column({ name: 'is_featured', default: false })
  isFeatured: boolean;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Qualification, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({
    name: 'qualification_code',
    referencedColumnName: 'code',
  })
  qualification: Qualification;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
