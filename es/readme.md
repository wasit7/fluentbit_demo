## Simple Tutorial: Insert Records into Elasticsearch and Create a Grafana Dashboard

This tutorial will walk you through two key tasks: inserting records into an Elasticsearch index using `curl` and creating a dashboard in Grafana to visualize that data. This is a beginner-friendly guide, perfect for getting started with these powerful tools for data storage and visualization.

---

### Prerequisites
Before you begin, ensure you have the following:
- **Elasticsearch**: Installed and running on `localhost:9200`. Download it from [elastic.co/downloads/elasticsearch](https://www.elastic.co/downloads/elasticsearch) if needed.
- **Grafana**: Installed and running on `localhost:3000`. Get it from [grafana.com/grafana/download](https://grafana.com/grafana/download).
- **curl**: A command-line tool for HTTP requests, typically pre-installed on most systems.

---

### Step 1: Insert Records into Elasticsearch
We'll insert sample HTTP log records into an Elasticsearch index named `http-logs`. Each record will include fields like `ip`, `method`, `path`, `status`, and `@timestamp`.

#### 1. Insert a Sample Record
Run the following command in your terminal to insert a document into Elasticsearch:

```bash
curl -X POST "http://localhost:9200/http-logs/_doc" -H "Content-Type: application/json" -d '{
  "ip": "192.168.1.100",
  "method": "GET",
  "path": "/index.html",
  "status": 200,
  "@timestamp": "2025-03-04T11:20:00Z"
}'
```

- **Explanation**:
  - `-X POST`: Specifies an HTTP POST request to create a new document.
  - `"http://localhost:9200/http-logs/_doc"`: The URL targets the `http-logs` index and the `_doc` endpoint for document insertion.
  - `-H "Content-Type: application/json"`: Sets the request header to indicate JSON data.
  - `-d '{...}'`: The JSON payload containing the record. If the `http-logs` index doesn’t exist, Elasticsearch creates it automatically.

#### 2. Insert Another Record (Optional)
To add more data for visualization, insert a second record:

```bash
curl -X POST "http://localhost:9200/http-logs/_doc" -H "Content-Type: application/json" -d '{
  "ip": "192.168.1.101",
  "method": "POST",
  "path": "/submit",
  "status": 201,
  "@timestamp": "2025-03-04T11:20:05Z"
}'
```

#### 3. Verify the Data
Confirm the records were inserted by querying the index:

```bash
curl -X GET "http://localhost:9200/http-logs/_search?pretty"
```

- **Output**: Look for the `"hits"` section in the JSON response. You should see your inserted records listed under `"hits"` > `"hits"`.

---

### Step 2: Set Up Elasticsearch as a Data Source in Grafana
Next, connect Grafana to your Elasticsearch index to enable data visualization.

#### 1. Log In to Grafana
- Open your browser and navigate to `http://localhost:3000`.
- Log in with your credentials (default is `admin`/`admin`, unless changed).

#### 2. Add a New Data Source
- Click the **gear icon (Configuration)** in the left sidebar.
- Select **Data Sources**.
- Click **Add data source**.
- Choose **Elasticsearch** from the list.

#### 3. Configure the Data Source
Fill in the settings as follows:
- **Name**: Enter a descriptive name, e.g., `Elasticsearch HTTP Logs`.
- **URL**: Set to `http://elasticsearch:9200` (adjust if your Elasticsearch instance is elsewhere).
- **Index name**: Type `http-logs`.
- **Time field name**: Enter `@timestamp` (this tells Grafana which field represents time).
- Leave other settings at their defaults.
- Click **Save & Test**. You should see a message like "Data source is working" if successful.

---

### Step 3: Create a Dashboard in Grafana
Now, create a dashboard to visualize your HTTP log data.

#### 1. Create a New Dashboard
- Click the **plus icon (Create)** in the left sidebar.
- Select **Dashboard**.
- Click **Add new panel**.

#### 2. Configure the First Panel (Time Series Graph)
- **Data Source**: Ensure it’s set to `Elasticsearch HTTP Logs`.
- **Query Section**:
  - Set **Metric** to `Count` (counts the number of log entries).
  - Under **Group by**, add a `Date Histogram`:
    - Field: `@timestamp`
    - Interval: `auto` (adjusts based on time range).
- **Result**: This creates a graph showing the number of log entries over time.

#### 3. Add More Visualizations (Optional)
Add additional panels to explore your data further:
- **Pie Chart (HTTP Methods)**:
  - Click **Add panel** in the dashboard toolbar.
  - Set visualization type to **Pie Chart**.
  - In **Query**:
    - Metric: `Count`.
    - Add a `Terms` aggregation on the `method` field.
  - This shows the distribution of HTTP methods (e.g., GET vs. POST).
- **Table (Recent Logs)**:
  - Add another panel.
  - Set visualization type to **Table**.
  - In **Query**, set Metric to `Raw Document` to display all fields.
  - Adjust the row limit if needed.

#### 4. Arrange and Save
- Drag and resize panels to organize your dashboard layout.
- Click the **save icon** (top right) to save your dashboard. Give it a name like `HTTP Logs Dashboard`.

---

### Conclusion
You’ve successfully:
1. Inserted records into Elasticsearch using `curl`.
2. Connected Grafana to Elasticsearch as a data source.
3. Created a dashboard with visualizations like a time series graph, pie chart, and table.

This is a basic setup you can build upon by:
- Inserting more data (e.g., via repeated `curl` commands or tools like Filebeat).
- Adding more panels or customizing visualizations.
- Exploring advanced features in the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) or [Grafana tutorials](https://grafana.com/docs/grafana/latest/).

Enjoy visualizing your data!