import { prisma } from './helper';

export const englishLanguage = {
  name: 'English',
  code: 'en',
};

export const polishLanguage = {
  name: 'Polski',
  code: 'pl',
};

export const seedLanguages = async () => {
  await prisma.language.createMany({ data: [englishLanguage, polishLanguage] });
};
