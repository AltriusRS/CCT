export interface LatticePackageManifest {
  package: {
    name: string;
    entrypoint: string;
    description?: string;
    version?: string; // Optional for now
  };
  dependencies?: {
    libs?: string[];
  };
  driver?: {
    supported_types: string[]; // List of Block/Peripheral IDs
  };
  metadata?: {
    install_path?: string;
  };
}

export interface LeanFileEntry {
  n: string; // filename
  s: string; // sha256
}

export interface LeanIndexPackage {
  p: string; // repo directory path
  f: LeanFileEntry[]; // list of files
  d?: string[]; // dependencies
  t?: string[]; // supported_types (for drivers)
  m?: {
    // metadata
    install_path?: string;
  };
}

export interface LatticeRepoIndex {
  repository: {
    name: string;
    updated: number;
  };
  p: Record<string, LeanIndexPackage>;
}
