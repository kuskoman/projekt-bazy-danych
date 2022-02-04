import 'dotenv/config';
import { seedChallenges } from './challenge';
import { seedChallengeParticipations } from './challengeParticipation';
import { seedChallengeSolutions } from './challengeSolution';
import { seedChallengeTypes } from './challengeType';
import { seedLanguages } from './languages';
import { seedUsers } from './users';
import { seedWords } from './words';

const main = async () => {
  const users = await seedUsers();
  await seedLanguages();
  const { polishWords, englishWords } = await seedWords();
  const challengeTypeIds = await seedChallengeTypes();
  const challenges = await seedChallenges({ englishWords, polishWords, challengeTypeIds });
  const challengeParticipations = await seedChallengeParticipations({ challenges, users });
  await seedChallengeSolutions({ polishWords, englishWords, challengeParticipations, challenges });
};

main();
