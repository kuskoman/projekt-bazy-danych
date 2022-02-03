import faker from '@faker-js/faker';
import { Prisma } from '@prisma/client';
import { hash } from 'bcrypt';
import { prisma, randomString } from './helper';

const SALT_ROUNDS = 1;
const USER_COUNT = 100;

export const seedUsers = async () => {
  const users: Prisma.UserCreateManyInput[] = [];

  for (let i = 0; i < USER_COUNT; i++) {
    const password = randomString();

    const user: Prisma.UserCreateManyInput = {
      name: faker.internet.userName(),
      passwordDigest: await hash(password, SALT_ROUNDS),
      email: faker.unique(faker.internet.email, undefined),
    };

    users.push(user);
  }

  await prisma.user.createMany({ data: users });

  return users;
};
