import { Axios } from 'axios';
const axios = new Axios({});
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient();

export const getUrl = async (url: string) => {
  const resp = await axios.get<string>(url);
  return resp.data;
};

export const shuffleArray = <T>(array: T[]): T[] => {
  const arrayCopy = [...array];
  for (let i = arrayCopy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arrayCopy[i], arrayCopy[j]] = [arrayCopy[j], arrayCopy[i]];
  }

  return arrayCopy;
};

export const randomString = () => (Math.random() + 1).toString(36);
