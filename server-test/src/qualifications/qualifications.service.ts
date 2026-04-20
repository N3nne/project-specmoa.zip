import {
  BadGatewayException,
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { XMLParser } from 'fast-xml-parser';
import { FindOptionsWhere, ILike, Repository } from 'typeorm';
import {
  Qualification,
  QualificationDifficulty,
} from './entities/qualification.entity';

type QualificationApiItem = {
  qualgbcd?: string;
  qualgbnm?: string;
  seriescd?: string;
  seriesnm?: string;
  jmcd?: string;
  jmfldnm?: string;
  obligfldcd?: string;
  obligfldnm?: string;
  mdobligfldcd?: string;
  mdobligfldnm?: string;
};

type QualificationQuery = {
  qualgbcd?: string;
  seriescd?: string;
  q?: string;
  featured?: string;
  difficulty?: string;
  primaryFieldCode?: string;
  sortBy?: string;
};

type UpdateQualificationMetadataInput = {
  difficulty?: string;
  expectedStudyMinutes?: number;
  displayColor?: string;
  isFeatured?: boolean;
};

@Injectable()
export class QualificationsService {
  constructor(
    @InjectRepository(Qualification)
    private readonly qualificationsRepository: Repository<Qualification>,
  ) {}

  private readonly parser = new XMLParser({
    ignoreAttributes: false,
    parseTagValue: true,
    trimValues: true,
  });

  async getQualifications(query: QualificationQuery) {
    const requestedTypes = this.parseQualificationTypes(query.qualgbcd);
    const normalizedSeries = query.seriescd?.trim();
    const searchTerm = query.q?.trim();
    const featuredOnly = query.featured?.trim() === 'true';
    const normalizedDifficulty = this.parseDifficulty(query.difficulty);
    const normalizedPrimaryFieldCode = query.primaryFieldCode?.trim();
    const sortBy = query.sortBy?.trim() || 'recommended';
    const baseFilter: FindOptionsWhere<Qualification> = {
      seriesCode: normalizedSeries,
      isFeatured: featuredOnly ? true : undefined,
      difficulty: normalizedDifficulty ?? undefined,
      primaryFieldCode: normalizedPrimaryFieldCode,
    };

    const typeFilters = requestedTypes.map<FindOptionsWhere<Qualification>>(
      (qualificationTypeCode) => ({
        ...baseFilter,
        qualificationTypeCode,
      }),
    );

    const where = searchTerm
      ? typeFilters.flatMap((filter) => [
          {
            ...filter,
            name: ILike(`%${searchTerm}%`),
          },
          {
            ...filter,
            code: ILike(`%${searchTerm}%`),
          },
          {
            ...filter,
            seriesName: ILike(`%${searchTerm}%`),
          },
        ])
      : typeFilters;

    const qualifications = await this.qualificationsRepository.find({
      where,
      order: this.resolveSortOrder(sortBy),
    });

    return {
      source: 'server_test.qualifications',
      requestedAt: new Date().toISOString(),
      filters: {
        qualgbcd: requestedTypes,
        seriescd: normalizedSeries ?? null,
        q: searchTerm ?? null,
        featured: featuredOnly,
        difficulty: normalizedDifficulty ?? null,
        primaryFieldCode: normalizedPrimaryFieldCode ?? null,
        sortBy,
      },
      totalCount: qualifications.length,
      items: qualifications,
    };
  }

  async getQualificationTabs() {
    const qualifications = await this.qualificationsRepository.find({
      order: {
        name: 'ASC',
      },
    });

    const primaryFieldMap = new Map<
      string,
      { code: string; label: string; count: number }
    >();
    const typeMap = new Map<string, { code: string; label: string; count: number }>();

    for (const qualification of qualifications) {
      if (qualification.primaryFieldCode && qualification.primaryFieldName) {
        const existingField = primaryFieldMap.get(qualification.primaryFieldCode);
        if (existingField) {
          existingField.count += 1;
        } else {
          primaryFieldMap.set(qualification.primaryFieldCode, {
            code: qualification.primaryFieldCode,
            label: qualification.primaryFieldName,
            count: 1,
          });
        }
      }

      const existingType = typeMap.get(qualification.qualificationTypeCode);
      if (existingType) {
        existingType.count += 1;
      } else {
        typeMap.set(qualification.qualificationTypeCode, {
          code: qualification.qualificationTypeCode,
          label: qualification.qualificationTypeName,
          count: 1,
        });
      }
    }

    const primaryFields = Array.from(primaryFieldMap.values())
      .sort((a, b) => b.count - a.count || a.label.localeCompare(b.label))
      .slice(0, 8);
    const qualificationTypes = Array.from(typeMap.values()).sort(
      (a, b) => b.count - a.count || a.label.localeCompare(b.label),
    );

    return {
      totalCount: qualifications.length,
      tabs: [
        { code: 'ALL', label: 'All', count: qualifications.length },
        ...qualificationTypes,
      ],
      primaryFields,
      difficulties: [
        { code: QualificationDifficulty.EASY, label: 'Easy' },
        { code: QualificationDifficulty.MEDIUM, label: 'Medium' },
        { code: QualificationDifficulty.HARD, label: 'Hard' },
      ],
      sorts: [
        { code: 'recommended', label: 'Recommended' },
        { code: 'name', label: 'Name' },
        { code: 'recent', label: 'Recent' },
      ],
    };
  }

  async getQualificationDetail(code: string) {
    const qualification = await this.qualificationsRepository.findOne({
      where: { code },
    });

    if (!qualification) {
      throw new NotFoundException(`Qualification not found: ${code}`);
    }

    return qualification;
  }

  async updateQualificationMetadata(
    code: string,
    input: UpdateQualificationMetadataInput,
  ) {
    const qualification = await this.qualificationsRepository.findOne({
      where: { code },
    });

    if (!qualification) {
      throw new NotFoundException(`Qualification not found: ${code}`);
    }

    if (typeof input.difficulty !== 'undefined') {
      qualification.difficulty = this.parseDifficulty(input.difficulty);
    }

    if (typeof input.expectedStudyMinutes !== 'undefined') {
      qualification.expectedStudyMinutes = input.expectedStudyMinutes ?? null;
    }

    if (typeof input.displayColor !== 'undefined') {
      qualification.displayColor = input.displayColor?.trim() || null;
    }

    if (typeof input.isFeatured !== 'undefined') {
      qualification.isFeatured = input.isFeatured;
    }

    return this.qualificationsRepository.save(qualification);
  }

  async syncQualifications(query: QualificationQuery) {
    const qualifications = await this.fetchQualificationsFromApi(query);

    if (!qualifications.length) {
      return {
        syncedCount: 0,
        message: 'No qualifications were returned from the external API.',
      };
    }

    await this.qualificationsRepository.upsert(qualifications, ['code']);

    return {
      syncedCount: qualifications.length,
      filters: {
        qualgbcd: this.parseQualificationTypes(query.qualgbcd),
        seriescd: query.seriescd?.trim() ?? null,
      },
    };
  }

  private async fetchQualificationsFromApi(query: QualificationQuery) {
    const serviceKey = process.env.QNET_SERVICE_KEY;
    const baseUrl =
      process.env.QNET_API_BASE_URL ??
      'http://openapi.q-net.or.kr/api/service/rest/InquiryListNationalQualifcationSVC/getList';

    if (!serviceKey) {
      throw new InternalServerErrorException(
        'QNET_SERVICE_KEY is not configured.',
      );
    }

    const url = new URL(baseUrl);
    url.searchParams.set('serviceKey', serviceKey);

    const response = await fetch(url);

    if (!response.ok) {
      throw new BadGatewayException(
        `Failed to fetch qualification data: ${response.status}`,
      );
    }

    const xml = await response.text();
    const parsed = this.parser.parse(xml);
    const body = parsed?.response?.body;
    const rawItems = body?.items?.item;
    const items = Array.isArray(rawItems)
      ? rawItems
      : rawItems
        ? [rawItems]
        : [];
    const requestedTypes = this.parseQualificationTypes(query.qualgbcd);
    const normalizedSeries = query.seriescd?.trim();

    return items
      .map((item: QualificationApiItem) => this.mapApiItemToEntity(item))
      .filter((item) => requestedTypes.includes(item.qualificationTypeCode))
      .filter((item) =>
        normalizedSeries ? item.seriesCode === normalizedSeries : true,
      );
  }

  private mapApiItemToEntity(item: QualificationApiItem) {
    return this.qualificationsRepository.create({
      qualificationTypeCode: item.qualgbcd ?? '',
      qualificationTypeName: item.qualgbnm ?? '',
      seriesCode: item.seriescd ?? '',
      seriesName: item.seriesnm ?? '',
      code: item.jmcd ?? '',
      name: item.jmfldnm ?? '',
      primaryFieldCode: item.obligfldcd ?? null,
      primaryFieldName: item.obligfldnm ?? null,
      secondaryFieldCode: item.mdobligfldcd ?? null,
      secondaryFieldName: item.mdobligfldnm ?? null,
    });
  }

  private parseDifficulty(difficulty?: string) {
    if (!difficulty?.trim()) {
      return null;
    }

    const normalizedDifficulty = difficulty.trim().toLowerCase();
    if (
      normalizedDifficulty !== QualificationDifficulty.EASY &&
      normalizedDifficulty !== QualificationDifficulty.MEDIUM &&
      normalizedDifficulty !== QualificationDifficulty.HARD
    ) {
      throw new BadRequestException(
        'difficulty must be one of: easy, medium, hard.',
      );
    }

    return normalizedDifficulty as QualificationDifficulty;
  }

  private resolveSortOrder(sortBy: string) {
    switch (sortBy) {
      case 'name':
        return {
          name: 'ASC' as const,
        };
      case 'recent':
        return {
          updatedAt: 'DESC' as const,
          createdAt: 'DESC' as const,
        };
      case 'recommended':
      default:
        return {
          isFeatured: 'DESC' as const,
          difficulty: 'ASC' as const,
          name: 'ASC' as const,
        };
    }
  }

  private parseQualificationTypes(qualgbcd?: string) {
    if (!qualgbcd?.trim()) {
      return ['T', 'S'];
    }

    return qualgbcd
      .split(',')
      .map((value) => value.trim().toUpperCase())
      .filter((value) => value === 'T' || value === 'S');
  }
}
