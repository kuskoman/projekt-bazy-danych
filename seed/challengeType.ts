import { prisma } from './helper';

export const daily = {
  name: 'daily',
} as const;

export const weekly = {
  name: 'weekly',
} as const;

export const inviteOnly = {
  name: 'private',
} as const;

export const seedChallengeTypes = async () => {
  await prisma.challengeType.createMany({ data: [daily, weekly, inviteOnly] });
  const challengeTypes = await prisma.challengeType.findMany();

  return challengeTypes.map(({ id }) => id);
};
