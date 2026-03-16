import { checkMissingTasks } from './missingTaskService.js';

//const INTERVAL_MS = 60 * 60 * 1000; // 1 ชั่วโมง
const INTERVAL_MS = 60 * 1000; // 1 นาที

export const startMissingTaskJob = (): void => {
  console.log('⏰ MissingTaskJob started — runs every 1 hour');

  // รันทันทีตอน server start
  checkMissingTasks().catch(console.error);

  // แล้วรันซ้ำทุก 1 ชั่วโมง
  setInterval(() => {
    checkMissingTasks().catch(console.error);
  }, INTERVAL_MS);
};
