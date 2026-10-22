-- Initial schema for Papa Cologne PH inventory.
CREATE TABLE `User` (
  `id` VARCHAR(191) NOT NULL,
  `email` VARCHAR(191) NOT NULL,
  `name` VARCHAR(191) NOT NULL,
  `passwordHash` VARCHAR(191) NOT NULL,
  `role` ENUM('OWNER','ADMIN','INVENTORY_STAFF','SALES_STAFF') NOT NULL DEFAULT 'SALES_STAFF',
  `active` BOOLEAN NOT NULL DEFAULT true,
  `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE INDEX `User_email_key`(`email`),
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `Fragrance` (
  `id` VARCHAR(191) NOT NULL,
  `brand` VARCHAR(191) NOT NULL,
  `name` VARCHAR(191) NOT NULL,
  `concentration` VARCHAR(191) NOT NULL DEFAULT '',
  UNIQUE INDEX `Fragrance_brand_name_concentration_key`(`brand`,`name`,`concentration`),
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `ProductSku` (
  `id` VARCHAR(191) NOT NULL,
  `fragranceId` VARCHAR(191) NOT NULL,
  `sku` VARCHAR(191) NOT NULL,
  `kind` ENUM('FULL_BOTTLE','DECANT') NOT NULL,
  `bottleVolumeMl` DECIMAL(8,2) NULL,
  `decantSizeMl` DECIMAL(8,2) NULL,
  `costPerUnit` DECIMAL(12,2) NOT NULL,
  `sellingPrice` DECIMAL(12,2) NOT NULL,
  `active` BOOLEAN NOT NULL DEFAULT true,
  `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE INDEX `ProductSku_sku_key`(`sku`),
  INDEX `ProductSku_kind_active_idx`(`kind`,`active`),
  PRIMARY KEY (`id`),
  CONSTRAINT `ProductSku_fragranceId_fkey` FOREIGN KEY (`fragranceId`) REFERENCES `Fragrance`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `InventoryBalance` (
  `id` VARCHAR(191) NOT NULL,
  `productSkuId` VARCHAR(191) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL DEFAULT 0,
  `remainingVolumeMl` DECIMAL(12,2) NOT NULL DEFAULT 0,
  `updatedAt` DATETIME(3) NOT NULL,
  UNIQUE INDEX `InventoryBalance_productSkuId_key`(`productSkuId`),
  PRIMARY KEY (`id`),
  CONSTRAINT `InventoryBalance_productSkuId_fkey` FOREIGN KEY (`productSkuId`) REFERENCES `ProductSku`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE `StockMovement` (
  `id` VARCHAR(191) NOT NULL,
  `productSkuId` VARCHAR(191) NOT NULL,
  `type` ENUM('PURCHASE','SALE','DECANT_PRODUCTION','RETURN','ADJUSTMENT') NOT NULL,
  `quantityDelta` DECIMAL(12,2) NOT NULL,
  `unit` VARCHAR(191) NOT NULL DEFAULT 'unit',
  `sourceSkuId` VARCHAR(191) NULL,
  `sourceVolumeMl` DECIMAL(8,2) NULL,
  `reason` VARCHAR(191) NULL,
  `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX `StockMovement_productSkuId_createdAt_idx`(`productSkuId`,`createdAt`),
  PRIMARY KEY (`id`),
  CONSTRAINT `StockMovement_productSkuId_fkey` FOREIGN KEY (`productSkuId`) REFERENCES `ProductSku`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `StockMovement`
  ADD COLUMN `reference` VARCHAR(191) NULL,
  ADD COLUMN `actorUserId` VARCHAR(191) NULL;
