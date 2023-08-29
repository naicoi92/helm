{{- define "template.spec" }}
    spec:
        volumes:
        {{- if or (eq .Values.rclone.from "local") (eq .Values.rclone.to "local") }}
            - name: local
              hostPath:
                path: {{ .Values.local.drive }}{{ .Values.local.path }}
                type: DirectoryOrCreate
        {{- end }}
        containers:
            - name: {{ .Release.Name }}
              image: {{ .Values.image }}
              command:
                - rclone
                - {{ .Values.rclone.action }}
                {{- if not .Values.rclone.debug }}
                - '-vv'
                {{- end }}
                {{- if eq .Values.rclone.from "local" }}
                - '/data'
                {{ else if eq .Values.rclone.from "s3" }}
                - 's3:{{ .Values.s3.bucket }}{{ .Values.s3.path }}'
                {{- else }}
                - '{{ .Values.rclone.from }}:'
                {{- end }}
                {{- if eq .Values.rclone.to "local" }}
                - '/data'
                {{ else if eq .Values.rclone.to "s3" }}
                - 's3:{{ .Values.s3.bucket }}{{ .Values.s3.path }}'
                {{- else }}
                - '{{ .Values.rclone.to }}:'
                {{- end }}
              volumeMounts:
            {{- if or (eq .Values.rclone.from "local") (eq .Values.rclone.to "local") }}
                - mountPath: /data
                  name: local
            {{- end }}
              envFrom:
                - configMapRef:
                    name: {{ .Release.Name }}
              imagePullPolicy: Always
        restartPolicy: Never
{{- end }}