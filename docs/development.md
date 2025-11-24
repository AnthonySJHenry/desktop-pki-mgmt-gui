# Development Notes

## Certificate Tracking - JSON Approach

Using a simple JSON file to track certificate metadata instead of a database. OpenSSL creates the actual cert files (`.key`, `.crt`, `.csr`, `.srl`), and we track their metadata separately.

### Data Structure

```go
type CertificateRecord struct {
    Name       string    `json:"name"`         // e.g., "MyRootCA", "ProductionServer"
    Type       string    `json:"type"`         // "root", "intermediate", "server"
    SerialNum  string    `json:"serial"`       // From .srl file
    IssueDate  time.Time `json:"issue_date"`
    ExpiryDate time.Time `json:"expiry_date"`
    Status     string    `json:"status"`       // "active", "expired", "revoked"
    CertPath   string    `json:"cert_path"`    // Path to .crt file
    KeyPath    string    `json:"key_path"`     // Path to .key file
    ParentCert string    `json:"parent_cert,omitempty"` // Name of signing cert (if intermediate/server)
}

type CertificateStore struct {
    Certificates []CertificateRecord `json:"certificates"`
}
```

### Storage Location

Store in `~/.pki-manager/certificates.json` or similar user-local directory.

### Example JSON

```json
{
  "certificates": [
    {
      "name": "MyRootCA",
      "type": "root",
      "serial": "00",
      "issue_date": "2025-01-15T10:30:00Z",
      "expiry_date": "2045-01-15T10:30:00Z",
      "status": "active",
      "cert_path": "/path/to/rootCA.crt",
      "key_path": "/path/to/rootCA.key"
    },
    {
      "name": "ProductionIntermediateCA",
      "type": "intermediate",
      "serial": "01",
      "issue_date": "2025-01-15T11:00:00Z",
      "expiry_date": "2030-01-15T11:00:00Z",
      "status": "active",
      "cert_path": "/path/to/intermediateCA.crt",
      "key_path": "/path/to/intermediateCA.key",
      "parent_cert": "MyRootCA"
    },
    {
      "name": "WebServer1",
      "type": "server",
      "serial": "02",
      "issue_date": "2025-01-15T12:00:00Z",
      "expiry_date": "2026-01-15T12:00:00Z",
      "status": "active",
      "cert_path": "/path/to/server.crt",
      "key_path": "/path/to/server.key",
      "parent_cert": "ProductionIntermediateCA"
    }
  ]
}
```

### Operations

**Load certificates:**
```go
func loadCertificates(path string) (*CertificateStore, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, err
    }
    var store CertificateStore
    err = json.Unmarshal(data, &store)
    return &store, err
}
```

**Save certificates:**
```go
func saveCertificates(path string, store *CertificateStore) error {
    data, err := json.MarshalIndent(store, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile(path, data, 0600)
}
```

**Add new certificate:**
```go
func (s *CertificateStore) AddCertificate(cert CertificateRecord) {
    s.Certificates = append(s.Certificates, cert)
}
```

**Find certificate by name:**
```go
func (s *CertificateStore) FindByName(name string) *CertificateRecord {
    for i := range s.Certificates {
        if s.Certificates[i].Name == name {
            return &s.Certificates[i]
        }
    }
    return nil
}
```

### GUI Integration

The Fyne GUI should:
1. Load `certificates.json` on startup
2. Display certificates in a list/table widget
3. Allow creating new certs (calls OpenSSL, then adds to JSON)
4. Allow viewing cert details
5. Show expiration warnings
6. Save JSON after any changes

### Future Enhancements

If the JSON approach becomes limiting:
- Migrate to SQLite (still file-based, no server needed)
- Or PostgreSQL if managing hundreds/thousands of certs
