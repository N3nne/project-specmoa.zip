import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { StudySession } from '../../study-sessions/entities/study-session.entity';
import { UserQualification } from '../../user-qualifications/entities/user-qualification.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, length: 150 })
  email: string;

  @Column({ name: 'display_name', length: 50 })
  displayName: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  password: string | null;

  @Column({ name: 'profile_image_url', type: 'varchar', nullable: true })
  profileImageUrl: string | null;

  @Column({ default: 1 })
  level: number;

  @Column({ name: 'streak_days', default: 0 })
  streakDays: number;

  @Column({ name: 'total_study_minutes', default: 0 })
  totalStudyMinutes: number;

  @Column({ name: 'earned_certificates_count', default: 0 })
  earnedCertificatesCount: number;

  @Column({ name: 'progress_rate', type: 'decimal', precision: 5, scale: 2, default: 0 })
  progressRate: number;

  @OneToMany(() => UserQualification, (userQualification) => userQualification.user)
  userQualifications: UserQualification[];

  @OneToMany(() => StudySession, (studySession) => studySession.user)
  studySessions: StudySession[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
