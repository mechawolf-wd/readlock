/// <reference types="vite/client" />

declare module 'vanta/dist/vanta.net.min' {
  const NET: (opts: any) => any
  export default NET
}

declare module 'vanta/dist/vanta.topology.min' {
  const TOPOLOGY: (opts: any) => any
  export default TOPOLOGY
}
