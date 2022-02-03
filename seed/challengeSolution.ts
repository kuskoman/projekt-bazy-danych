import faker from '@faker-js/faker';
import { Challenge, ChallengeParticipation } from '@prisma/client';
import { prisma, randomNumberBetween } from './helper';

const MAX_TRIES = 8;

export const seedChallengeSolutions = async ({
  polishWords,
  englishWords,
  challengeParticipations,
  challenges,
}: SeedChallengeSolutionsInput) => {
  const getDictionary = (langCode: string) => {
    if (langCode === 'en') {
      return englishWords;
    }

    if (langCode == 'pl') {
      return polishWords;
    }

    throw new Error(`Language code ${langCode} not known`);
  };

  const solutions = challengeParticipations.flatMap((participation) => {
    const isGuessed = randomNumberBetween(0, 2) !== 2;
    const invalidGuesses = randomNumberBetween(1, MAX_TRIES) - +isGuessed;

    const challenge = challenges.find((c) => c.uuid === participation.challengeUuid);
    const dictionary = getDictionary(challenge.wordLanguageCode)
      .filter((w) => w.length === challenge.wordContent.length)
      .filter((w) => w !== challenge.wordContent);

    if (dictionary.length === 0) {
      return [];
    }

    return faker.random
      .arrayElements(dictionary, invalidGuesses)
      .concat(isGuessed ? [challenge.wordContent] : [])
      .map((guess) => ({ guess, challengeUuid: challenge.uuid, userUuid: participation.userUuid }));
  });

  await prisma.challengeSolution.createMany({ data: solutions });
};

interface SeedChallengeSolutionsInput {
  polishWords: string[];
  englishWords: string[];
  challengeParticipations: ChallengeParticipation[];
  challenges: Challenge[];
}
