/*
  Warnings:

  - You are about to drop the `accounts` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `categories` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `transactions` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."accounts" DROP CONSTRAINT "accounts_user_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."categories" DROP CONSTRAINT "categories_user_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."transactions" DROP CONSTRAINT "transactions_account_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."transactions" DROP CONSTRAINT "transactions_category_id_fkey";

-- DropTable
DROP TABLE "public"."accounts";

-- DropTable
DROP TABLE "public"."categories";

-- DropTable
DROP TABLE "public"."transactions";

-- DropEnum
DROP TYPE "public"."CategoryType";

-- DropEnum
DROP TYPE "public"."TransactionType";

-- CreateTable
CREATE TABLE "public"."shortened_urls" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "original_url" TEXT NOT NULL,
    "short_code" TEXT NOT NULL,
    "title" TEXT,
    "description" TEXT,
    "clicks" INTEGER NOT NULL DEFAULT 0,
    "expires_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "shortened_urls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."url_analytics" (
    "id" SERIAL NOT NULL,
    "url_id" INTEGER NOT NULL,
    "user_agent" TEXT,
    "referer" TEXT,
    "ip_address" TEXT,
    "country" TEXT,
    "clicked_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "url_analytics_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "shortened_urls_short_code_key" ON "public"."shortened_urls"("short_code");

-- CreateIndex
CREATE INDEX "shortened_urls_short_code_idx" ON "public"."shortened_urls"("short_code");

-- CreateIndex
CREATE INDEX "shortened_urls_user_id_idx" ON "public"."shortened_urls"("user_id");

-- CreateIndex
CREATE INDEX "url_analytics_url_id_idx" ON "public"."url_analytics"("url_id");

-- CreateIndex
CREATE INDEX "url_analytics_clicked_at_idx" ON "public"."url_analytics"("clicked_at");

-- AddForeignKey
ALTER TABLE "public"."shortened_urls" ADD CONSTRAINT "shortened_urls_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."url_analytics" ADD CONSTRAINT "url_analytics_url_id_fkey" FOREIGN KEY ("url_id") REFERENCES "public"."shortened_urls"("id") ON DELETE CASCADE ON UPDATE CASCADE;
