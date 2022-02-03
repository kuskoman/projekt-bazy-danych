import faker from '@faker-js/faker';
import { Prisma } from '@prisma/client';
import { prisma } from './helper';
import { englishLanguage, polishLanguage } from './languages';

const CHALLENGE_COUNT = 200;

export const seedChallenges = async ({
  englishWords,
  polishWords,
  challengeTypeIds,
}: SeedChallengesInput) => {
  const challenges: Prisma.ChallengeCreateManyInput[] = [];

  for (let i = 0; i < CHALLENGE_COUNT; i++) {
    const language = faker.random.arrayElement([englishLanguage, polishLanguage]);
    const wordLanguageCode = language.code;

    const word = (() => {
      if (wordLanguageCode === englishLanguage.code) {
        return faker.random.arrayElement(englishWords);
      }

      if (wordLanguageCode === polishLanguage.code) {
        return faker.random.arrayElement(polishWords);
      }

      throw new Error(`Unknown language code ${wordLanguageCode}`);
    })();

    const type = faker.random.arrayElement(challengeTypeIds);

    const challenge: Prisma.ChallengeCreateManyInput = {
      wordContent: word,
      challengeTypeId: type,
      wordLanguageCode,
    };

    challenges.push(challenge);
  }

  await prisma.challenge.createMany({ data: challenges });
};

interface SeedChallengesInput {
  englishWords: string[];
  polishWords: string[];
  challengeTypeIds: number[];
}
