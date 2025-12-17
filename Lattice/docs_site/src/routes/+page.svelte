<script lang="ts">
  const installCommand = "wget run https://lattice-os.cc/install";
</script>

<svelte:head>
  <title>Lattice OS</title>
  <meta
    name="description"
    content="Lattice is a grid-first operating system for ComputerCraft: Tweaked, designed for AllTheMods 10."
  />
</svelte:head>

<main class="min-h-screen bg-neutral-950 text-neutral-200">
  <div class="mx-auto max-w-3xl px-6 py-20">
    <!-- Header -->
    <header class="mb-16">
      <h1 class="text-4xl font-semibold tracking-tight text-neutral-100">
        LATTICE
      </h1>

      <p class="mt-4 text-lg text-neutral-400">
        A grid-first operating system for ComputerCraft: Tweaked<br />
        <span class="text-neutral-500">
          Designed for the AllTheMods 10 modpack
        </span>
      </p>
    </header>

    <!-- Intro -->
    <section class="space-y-4 text-neutral-300">
      <p>
        Lattice is a lightweight, modular operating system built for
        <strong class="text-neutral-100">ComputerCraft: Tweaked</strong>.
      </p>

      <p>
        It treats every computer as a
        <strong class="text-neutral-100">node in a grid</strong> — structured,
        predictable, and extensible.
      </p>

      <p class="text-neutral-400">
        Bootstrapped cleanly. Expanded deliberately.
      </p>
    </section>

    <hr class="my-16 border-neutral-800" />

    <!-- What is Lattice -->
    <section class="space-y-6">
      <h2 class="text-2xl font-medium text-neutral-100">
        What is Lattice?
      </h2>

      <p class="text-neutral-300">
        Lattice is not a single program.
      </p>

      <ul class="list-disc space-y-2 pl-5 text-neutral-300">
        <li>A minimal bootloader</li>
        <li>A shared library grid</li>
        <li>A manifest-driven installer</li>
        <li>
          A foundation for automation, monitoring, and orchestration
        </li>
      </ul>

      <p class="text-neutral-400">
        Think <strong>blocks</strong>, not blobs.
      </p>
    </section>

    <hr class="my-16 border-neutral-800" />

    <!-- Installation -->
    <section class="space-y-6">
      <h2 class="text-2xl font-medium text-neutral-100">
        Installation
      </h2>

      <p class="text-neutral-300">
        From an <strong>Advanced Computer</strong>, run:
      </p>

      <pre
        class="rounded-lg border border-neutral-800 bg-neutral-900 p-4 text-sm text-neutral-100"
      >
<code>{installCommand}</code>
      </pre>

      <p class="text-neutral-400">
        You’ll know it’s working when the screen starts talking back.
      </p>
    </section>

    <hr class="my-16 border-neutral-800" />

    <!-- Philosophy -->
    <section class="space-y-6">
      <h2 class="text-2xl font-medium text-neutral-100">
        Philosophy
      </h2>

      <ul class="list-disc space-y-2 pl-5 text-neutral-300">
        <li><strong>Explicit over implicit</strong></li>
        <li><strong>Structure over sprawl</strong></li>
        <li><strong>Modules over monoliths</strong></li>
        <li>
          <strong>Automation is a feature, not an afterthought</strong>
        </li>
      </ul>

      <p class="text-neutral-400">
        If something fails, it should fail loudly and clearly.
      </p>
    </section>

    <hr class="my-16 border-neutral-800" />

    <!-- Footer -->
    <footer class="space-y-2 text-sm text-neutral-500">
      <p>
        <strong class="text-neutral-400">Lattice OS</strong><br />
        Constructing the grid.
      </p>

      <p>
        Source:
        <a
          href="https://github.com/AltriusRS/CCT"
          class="text-neutral-300 hover:underline"
        >
          GitHub
        </a>
      </p>
    </footer>
  </div>
</main>
