import { getUrl, prisma, shuffleArray } from './helper';
import { englishLanguage, polishLanguage } from './languages';

const ENGLISH_DICTIONARY_URL = 'https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt';
const POLISH_DICTIONARY_URL =
  'https://raw.githubusercontent.com/turekj/msc/master/CheatAR/development/server/word-dictionary-importer/src/main/resources/scrabble-polish-words.txt';

export const seedWords = async () => {
  const englishWords = await getUrl(ENGLISH_DICTIONARY_URL);

  const mapWords = (words: string, languageCode: string) =>
    shuffleArray(words.split('\n'))
      .slice(0, 1000)
      .map((word) => ({ word, length: word.length, languageCode }));

  const englishWordsEntries = mapWords(englishWords, englishLanguage.code);

  const polishWords = await getUrl(POLISH_DICTIONARY_URL);
  const polishWordsEntries = mapWords(polishWords, polishLanguage.code);

  const allWords = [...englishWordsEntries, ...polishWordsEntries];

  await prisma.word.createMany({ data: allWords });

  return { polishWords: polishWordsEntries.map((w) => w.word), englishWords: englishWordsEntries.map((w) => w.word) };
};
