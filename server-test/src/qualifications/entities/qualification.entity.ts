import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserQualification } from '../../user-qualifications/entities/user-qualification.entity';

export enum QualificationDifficulty {
  EASY = 'easy',
  MEDIUM = 'medium',
  HARD = 'hard',
}

@Entity('qualifications')
export class Qualification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, length: 50 })
  code: string;

  @Column({ length: 100 })
  name: string;

  @Column({ name: 'qualification_type_code', length: 10 })
  qualificationTypeCode: string;

  @Column({ name: 'qualification_type_name', length: 100 })
  qualificationTypeName: string;

  @Column({ name: 'series_code', length: 20 })
  seriesCode: string;

  @Column({ name: 'series_name', length: 100 })
  seriesName: string;

  @Column({ name: 'primary_field_code', type: 'varchar', length: 20, nullable: true })
  primaryFieldCode: string | null;

  @Column({ name: 'primary_field_name', type: 'varchar', length: 100, nullable: true })
  primaryFieldName: string | null;

  @Column({ name: 'secondary_field_code', type: 'varchar', length: 20, nullable: true })
  secondaryFieldCode: string | null;

  @Column({ name: 'secondary_field_name', type: 'varchar', length: 100, nullable: true })
  secondaryFieldName: string | null;

  @Column({
    type: 'enum',
    enum: QualificationDifficulty,
    nullable: true,
  })
  difficulty: QualificationDifficulty | null;

  @Column({ name: 'expected_study_minutes', type: 'int', nullable: true })
  expectedStudyMinutes: number | null;

  @Column({ name: 'display_color', type: 'varchar', length: 20, nullable: true })
  displayColor: string | null;

  @Column({ name: 'is_featured', default: false })
  isFeatured: boolean;

  @OneToMany(
    () => UserQualification,
    (userQualification) => userQualification.qualification,
  )
  userQualifications: UserQualification[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
