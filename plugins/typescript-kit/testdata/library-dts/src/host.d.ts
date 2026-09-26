export interface HostPlugin {
  options?: any
  parse(text: string, options?: any): unknown
}
