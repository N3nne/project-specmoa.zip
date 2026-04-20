import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserQualification } from '../../user-qualifications/entities/user-qualification.entity';
import { User } from '../../users/entities/user.entity';

@Entity('study_sessions')
export class StudySession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'user_qualification_id' })
  userQualificationId: string;

  @ManyToOne(() => User, (user) => user.studySessions, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(
    () => UserQualification,
    (userQualification) => userQualification.studySessions,
    {
      onDelete: 'CASCADE',
    },
  )
  @JoinColumn({ name: 'user_qualification_id' })
  userQualification: UserQualification;

  @Column({ name: 'started_at', type: 'timestamptz' })
  startedAt: Date;

  @Column({ name: 'ended_at', type: 'timestamptz', nullable: true })
  endedAt: Date | null;

  @Column({ name: 'duration_seconds', default: 0 })
  durationSeconds: number;

  @Column({ name: 'goal_duration_seconds', type: 'int', nullable: true })
  goalDurationSeconds: number | null;

  @Column({ type: 'text', nullable: true })
  memo: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
