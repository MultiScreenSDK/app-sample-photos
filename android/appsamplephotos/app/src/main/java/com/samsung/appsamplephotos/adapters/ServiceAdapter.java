package com.samsung.appsamplephotos.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.samsung.appsamplephotos.R;
import com.samsung.appsamplephotos.fragments.ServiceFragment;
import com.samsung.multiscreen.Service;

import java.util.List;

public class ServiceAdapter extends BaseAdapter {

    private static LayoutInflater inflater = null;
    private Context context;
    private List<Service> dataSource;

    public ServiceAdapter(Context context, List<Service> dataSource) {
        inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        this.dataSource = dataSource;
        this.context = context;
    }

    static class ViewHolder {
        public TextView deviceName;
        public int position;
    }
	
	@Override
	public int getCount() {
		return dataSource.size();
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

    @Override
    public Object getItem(int position) {
        return dataSource.get(position);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;

        if (row == null) {
            row = inflater.inflate(R.layout.cell_service_layout, parent, false);
            ViewHolder holder = new ViewHolder();
            holder.deviceName = (TextView) row.findViewById(R.id.deviceName);
            row.setTag(holder);
        }

        final ViewHolder holder = (ViewHolder) row.getTag();

        final Service service = dataSource.get(position);

        holder.position = position;

        holder.deviceName.setText(service.getName());

        row.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ((ServiceFragment) context).selectedService(service);
            }
        });

        return row;
    }

}
