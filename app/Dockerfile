WORKDIR /app

# Install system dependency
RUN apt-get update && apt-get install -y
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependency
COPY requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copu application code
COPY . .

# Create unprivileged user
RUN useradd -m -s /bin/bash appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]