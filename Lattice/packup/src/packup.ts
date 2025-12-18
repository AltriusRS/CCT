import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import TOML from "@iarna/toml";
import { parseArgs } from "util"; // Bun/Node built-in for CLI args
import type {
  LatticePackageManifest,
  LatticeRepoIndex,
  LeanIndexPackage,
} from "./types/manifest";

/**
 * CLI Argument Setup
 */
const { values: args } = parseArgs({
  args: Bun.argv,
  options: {
    dir: {
      type: "string",
      short: "d",
      default: "pkg",
    },
    out: {
      type: "string",
      short: "o",
      default: "index.toml",
    },
  },
  strict: true,
  allowPositionals: true,
});

const WORKING_DIR = path.resolve(args.dir!);
const OUT_FILE = path.join(WORKING_DIR, args.out!);

console.debug("Working directory:", WORKING_DIR);
console.debug("Output file:", OUT_FILE);

/**
 * Calculates SHA256 hash of a file
 */
function getFileHash(filePath: string): string {
  if (!fs.existsSync(filePath)) return "";
  const buffer = fs.readFileSync(filePath);
  return crypto.createHash("sha256").update(buffer).digest("hex");
}

/**
 * Recursively crawls the directory to find lattice.toml manifests
 */
function crawl(
  dir: string,
  packages: Record<string, LeanIndexPackage> = {},
): Record<string, LeanIndexPackage> {
  if (!fs.existsSync(dir)) return packages;

  const files = fs.readdirSync(dir);

  if (files.includes("lattice.toml")) {
    const manifestPath = path.join(dir, "lattice.toml");
    const rawContent = fs.readFileSync(manifestPath, "utf-8");

    const manifest = TOML.parse(
      rawContent,
    ) as unknown as LatticePackageManifest;
    const relPath = path.relative(WORKING_DIR, dir).replace(/\\/g, "/");

    // Get all files in the package directory except the manifest
    const packageFiles = fs
      .readdirSync(dir)
      .filter((file) => file !== "lattice.toml")
      .map((file) => ({
        n: file,
        s: getFileHash(path.join(dir, file)),
      }));

    packages[manifest.package.name] = {
      p: relPath,
      f: packageFiles, // Now indexing all files in the folder
      d: manifest.dependencies?.libs,
      t: manifest.driver?.supported_types,
      m: manifest.metadata,
    };

    console.log(`[INDEXED] ${manifest.package.name}`);
    return packages;
  }

  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      crawl(fullPath, packages);
    }
  }

  return packages;
}

/**
 * Main execution
 */
function build() {
  console.log(`Lattice Packer v0.2.0`);
  console.log(`Working Directory: ${WORKING_DIR}`);

  if (!fs.existsSync(WORKING_DIR)) {
    console.error(`Error: Directory ${WORKING_DIR} does not exist.`);
    process.exit(1);
  }

  const registry: LatticeRepoIndex = {
    repository: {
      name: "Lattice Official",
      updated: Math.floor(Date.now() / 1000),
    },
    p: crawl(WORKING_DIR),
  };

  const output = TOML.stringify(registry as any);
  fs.writeFileSync(OUT_FILE, output);

  console.log(`\nSuccess: Index written to ${OUT_FILE}`);
  console.log(`Total Packages: ${Object.keys(registry.p).length}`);
}

build();
