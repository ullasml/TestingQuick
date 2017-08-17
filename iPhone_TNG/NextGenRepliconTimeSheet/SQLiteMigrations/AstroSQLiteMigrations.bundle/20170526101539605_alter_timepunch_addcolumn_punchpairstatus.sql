ALTER TABLE "time_punch" ADD COLUMN "previousPunchPairStatus" NUMERIC;
ALTER TABLE "time_punch" ADD COLUMN "nextPunchPairStatus" NUMERIC;
ALTER TABLE "time_punch" ADD COLUMN "nonActionedValidationsCount" NUMERIC;
ALTER TABLE "time_punch" ADD COLUMN "sourceOfPunch" NUMERIC;
ALTER TABLE "time_punch" ADD COLUMN "duration" DATE;
