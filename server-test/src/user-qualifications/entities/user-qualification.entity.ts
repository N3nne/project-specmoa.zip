import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm';
import { Qualification } from '../../qualifications/entities/qualification.entity';
import { StudySession } from '../../study-sessions/entities/study-session.entity';
import { User } from '../../users/entities/user.entity';

export enum UserQualificationStatus {
  PREPARING = 'preparing',
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
}

@Entity('user_qualifications')
@Unique(['userId', 'qualificationId'])
export class UserQualification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'qualification_id' })
  qualificationId: string;

  @ManyToOne(() => User, (user) => user.userQualifications, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(
    () => Qualification,
    (qualification) => qualification.userQualifications,
    {
      onDelete: 'CASCADE',
    },
  )
  @JoinColumn({ name: 'qualification_id' })
  qualification: Qualification;

  @Column({
    type: 'enum',
    enum: UserQualificationStatus,
    default: UserQualificationStatus.PREPARING,
  })
  status: UserQualificationStatus;

  @Column({ name: 'exam_date', type: 'date', nullable: true })
  examDate: string | null;

  @Column({ name: 'started_at', type: 'timestamptz', nullable: true })
  startedAt: Date | null;

  @Column({ name: 'completed_at', type: 'timestamptz', nullable: true })
  completedAt: Date | null;

  @Column({ name: 'last_studied_at', type: 'timestamptz', nullable: true })
  lastStudiedAt: Date | null;

  @Column({ name: 'total_study_minutes', default: 0 })
  totalStudyMinutes: number;

  @Column({ name: 'sort_order', default: 0 })
  sortOrder: number;

  @Column({ name: 'is_pinned', default: false })
  isPinned: boolean;

  @OneToMany(() => StudySession, (studySession) => studySession.userQualification)
  studySessions: StudySession[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
