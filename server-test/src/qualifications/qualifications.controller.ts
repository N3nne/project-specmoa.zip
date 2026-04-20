import { Body, Controller, Get, Param, Patch, Post, Query } from '@nestjs/common';
import { QualificationsService } from './qualifications.service';

@Controller('qualifications')
export class QualificationsController {
  constructor(
    private readonly qualificationsService: QualificationsService,
  ) {}

  @Post('sync')
  syncQualifications(
    @Query('qualgbcd') qualgbcd?: string,
    @Query('seriescd') seriescd?: string,
  ) {
    return this.qualificationsService.syncQualifications({
      qualgbcd,
      seriescd,
    });
  }

  @Get()
  getQualifications(
    @Query('qualgbcd') qualgbcd?: string,
    @Query('seriescd') seriescd?: string,
    @Query('q') q?: string,
    @Query('featured') featured?: string,
    @Query('difficulty') difficulty?: string,
    @Query('primaryFieldCode') primaryFieldCode?: string,
    @Query('sortBy') sortBy?: string,
  ) {
    return this.qualificationsService.getQualifications({
      qualgbcd,
      seriescd,
      q,
      featured,
      difficulty,
      primaryFieldCode,
      sortBy,
    });
  }

  @Get('categories/tabs')
  getQualificationTabs() {
    return this.qualificationsService.getQualificationTabs();
  }

  @Get(':code')
  getQualificationDetail(@Param('code') code: string) {
    return this.qualificationsService.getQualificationDetail(code);
  }

  @Patch(':code/metadata')
  updateQualificationMetadata(
    @Param('code') code: string,
    @Body('difficulty') difficulty?: string,
    @Body('expectedStudyMinutes') expectedStudyMinutes?: number,
    @Body('displayColor') displayColor?: string,
    @Body('isFeatured') isFeatured?: boolean,
  ) {
    return this.qualificationsService.updateQualificationMetadata(code, {
      difficulty,
      expectedStudyMinutes,
      displayColor,
      isFeatured,
    });
  }
}
