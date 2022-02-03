import { seedChallenges } from './challenge';
import { seedChallengeTypes } from './challengeType';
import { seedLanguages } from './languages';
import { seedUsers } from './users';
import { seedWords } from './words';

const main = async () => {
  const users = await seedUsers();
  await seedLanguages();
  const { polishWords, englishWords } = await seedWords();
  const challengeTypeIds = await seedChallengeTypes();
  await seedChallenges({ englishWords, polishWords, challengeTypeIds });
};

main();
