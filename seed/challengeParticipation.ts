import { Challenge, Prisma, User } from '@prisma/client';
import { prisma, randomNumberBetween } from './helper';

export const seedChallengeParticipations = async ({
  challenges,
  users,
}: SeedChallengeParticipationsInput) => {
  const randomChallengePart = challenges.filter(() => {
    return randomNumberBetween(0, 10) !== 5;
  });

  const participations: Prisma.ChallengeParticipationCreateManyInput[] =
    randomChallengePart.flatMap((challenge) => {
      const numberOfParticipations = randomNumberBetween(1, 4);
      const firstUserIndex = randomNumberBetween(0, users.length - numberOfParticipations - 1);
      const choosenUsers = users.slice(firstUserIndex, firstUserIndex + numberOfParticipations);

      return choosenUsers.map((user) => {
        const participation: Prisma.ChallengeParticipationCreateManyInput = {
          challengeUuid: challenge.uuid,
          userUuid: user.uuid,
        };

        return participation;
      });
    });

  await prisma.challengeParticipation.createMany({ data: participations });
  return await prisma.challengeParticipation.findMany();
};

interface SeedChallengeParticipationsInput {
  challenges: Challenge[];
  users: User[];
}
