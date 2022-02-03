import { seedChallenges } from './challenge';
import { seedChallengeParticipations } from './challengeParticipation';
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
  await seedChallengeParticipations({ challenges, users });
};

main();
